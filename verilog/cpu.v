/*
RAM: 8 bit address bus
ROM: 16 bit address bus

instruction byte: hhhh llll
    hhhh: OPCODE
    llll: OPERAND

Registers: 
    A: byte
    B: byte
    X: byte
    PC: word
    Out: byte[16]
    In: byte[16]

Conditions: 
    z: A is zero
    m: A is minus (negative)
    c: Carry flag set
    i: Invert all conditions
	  Note 1: Z is least significant bit on operand
		Note 2: If condition is one, that flag must be true to execute instruction. If condition is zero, that flag will ignored
		Note 3: To execute instruction, all considered flags must be true.
		Note 4: Invert bit always invert the result of condition testing. 1000 will always skip instruction and 0000 will always execute instruction
		Note 5: Instructions pha out and inp always execute, ignoring conditions

Instruction set:
0x0 - tab {cond} : Transfer A to B
0x1 - sax {cond} : Swap A and X
0x2 - sta {cond} : Store to A from RAM using B as address
0x3 - lda {cond} : Load to A from RAM using B as address
0x4 - jmp {cond} : Push A and B to PC : A + (B<<8) => PC
0x5 - pha 0bxxxx : Push 4 bit to A
0x6 - out 0bxxxx : Put A to selected Out port
0x7 - inp 0bxxxx : Put selected Out port to A
0x8 - add {cond} : Add B to A
0x9 - sub {cond} : Subtract B from A
0xA - inc {cond} : Increment A
0xB - dec {cond} : Decrement A
0xC - and {cond} : And operation B to A
0xD - ora {cond} : Or operation B to A
0xE - xor {cond} : Xor operation B to A 
0xF - not {cond} : Invert all bits in A
*/

//-----------------------------------------------------------------------------
module cpu(
  input clk, rst,            // Saat ve reset sinyali   
  output [15:0] rom_address, // Program sayacı çıktısı
  input [7:0] rom_data,      // Komut girişi
  output [3:0] io_sel,       // G/Ç port seçimi çıktısı
  output io_reading,         // Girdi okuma sinyali
  output io_output,          // Çıktı yazma sinyali
  inout [7:0] io_data        // G/Ç veri hattı
);
  reg [7:0] RAM[256];
  reg [15:0] program_counter;
  reg [7:0] reg_a;
  reg [7:0] reg_b;
  reg [7:0] reg_x;

  wire [3:0] opcode = rom_data[7:4];
  wire [3:0] operand = rom_data[3:0];
  wire [2:0] condition = operand[2:0];
  wire invert_condition = operand[3];
  wire execute;

  wire [7:0]alu_result;
  wire alu_carry;
  wire alu_carry_set;
  
  reg zero_latch;
  reg minus_latch;
  reg carry_latch;
  
  (* keep *)
  ALU alu_instance (
    .A(reg_a),
    .B(reg_b),
    .operation(opcode[2:0]), 
    .result(alu_result),
    .carry(alu_carry),
    .carry_set(alu_carry_set)
  );

  initial begin // Yazmaçların başlangıç değeri              
    zero_latch = 0;
    minus_latch = 0;
    carry_latch = 0;
    program_counter = 0;
    reg_a = 0;
    reg_b = 0;
    reg_x = 0;
  end

  assign io_sel = (opcode == 4'b0110 || opcode == 4'b0111) ? operand : 4'b0000;
  assign io_output = (opcode == 4'b0110) ? 1'b1 : 1'b0;
  assign io_data = (opcode == 4'b0110) ? reg_a : 8'bzzzzzzzz; // 
  assign io_reading = (opcode == 4'b0111) ? 1'b1 : 1'b0;
  assign rom_address = program_counter;

  wire cond_z = condition[0] ? zero_latch : 1'b1;
  wire cond_m = condition[1] ? minus_latch : 1'b1;
  wire cond_c = condition[2] ? carry_latch : 1'b1;
  wire all_conditions = cond_z & cond_m & cond_c;
  assign execute = invert_condition ? ~all_conditions : all_conditions;

// Program counter update, JMP and INP instruction
  always @ (negedge clk) begin
    //...
    if(execute && opcode == 4'b0100) program_counter <= {reg_b, reg_a};
    else program_counter <= program_counter + 1;
    //...
    if(execute && opcode == 4'b0111) reg_a <= io_data;
  end


  always @ (posedge clk) begin
    if(opcode[3]) begin
      if(execute) begin 
        if(alu_carry_set) carry_latch <= alu_carry;
        zero_latch <= (alu_result == 0) ? 1'b1 : 1'b0;
        minus_latch <= (alu_result[7] == 1'b1) ? 1'b1 : 1'b0;
        reg_a <= alu_result;
      end
    end else begin
      case (opcode[2:0])
        3'b000: if(execute) reg_b <= reg_a; // tab
        3'b001: if(execute) begin // sax
                  reg_a <= reg_x;
                  reg_x <= reg_a;
                end
        3'b010: if(execute) RAM[reg_b] <= reg_a; // sta
        3'b011: if(execute) reg_a <= RAM[reg_b]; // lda
        3'b101: reg_a <= {reg_a[3:0], operand}; // pha
      endcase
    end
  end


// Reset logic
  always @ (*) begin
    if(rst) begin
      zero_latch = 0;
      minus_latch = 0;
      carry_latch = 0;
      reg_a <= 0;
      reg_b <= 0;
      reg_x <= 0;
      program_counter <= 0;
    end
  end


endmodule
//-----------------------------------------------------------------------------
module ALU(
  input [7:0] A,
  input [7:0] B,
  input [2:0] operation,
  output [7:0] result,
  output carry,
  output carry_set 
);
  wire [7:0] op_add_res;
  wire op_add_carry;
  wire [7:0] op_sub_res;
  wire op_sub_carry;
  wire [7:0] op_inc_res;
  wire op_inc_carry;
  wire [7:0] op_dec_res;
  wire op_dec_carry;
  wire [7:0] op_and_res;
  wire [7:0] op_ora_res;
  wire [7:0] op_xor_res;
  wire [7:0] op_not_res;

  assign {op_add_carry, op_add_res} = A + B; // Addition
  assign {op_sub_carry, op_sub_res} = A - B; // Subtraction
  assign {op_inc_carry, op_inc_res} = A + 1; // Increment
  assign {op_dec_carry, op_dec_res} = A - 1; // Decrement
  assign op_and_res = A & B; // And
  assign op_ora_res = A | B; // Or
  assign op_xor_res = A ^ B; // Xor
  assign op_not_res = ~A; // Not

  mux1_8to1 mux_carry_set (
    .in0(1'b1), // Addition
    .in1(1'b1), // Subtraction
    .in2(1'b1), // Increment
    .in3(1'b1), // Decrement
    .in4(1'b0), // And
    .in5(1'b0), // Or
    .in6(1'b0), // Xor
    .in7(1'b0), // Not
    .sel(operation),
    .out(carry_set)
  );

  mux1_8to1 mux_carry(
    .in0(op_add_carry), // Addition
    .in1(op_sub_carry), // Subtraction
    .in2(op_inc_carry), // Increment
    .in3(op_dec_carry), // Decrement
    .in4(1'b0), // And
    .in5(1'b0), // Or
    .in6(1'b0), // Xor
    .in7(1'b0), // Not
    .sel(operation),
    .out(carry)
  );

  mux8_8to1 mux_result(
    .in0(op_add_res), // Addition
    .in1(op_sub_res), // Subtraction
    .in2(op_inc_res), // Increment
    .in3(op_dec_res), // Decrement
    .in4(op_and_res), // And
    .in5(op_ora_res), // Or
    .in6(op_xor_res), // Xor
    .in7(op_not_res), // Not
    .sel(operation),
    .out(result)
  );
  
endmodule

//-----------------------------------------------------------------------------
module mux1_8to1(
  input in0,
  input in1,
  input in2,
  input in3,
  input in4,
  input in5,
  input in6,
  input in7,
  input [2:0] sel,
  output out
);
  assign out = (sel == 3'b000) ? in0 :
               (sel == 3'b001) ? in1 :
               (sel == 3'b010) ? in2 :
               (sel == 3'b011) ? in3 :
               (sel == 3'b100) ? in4 :
               (sel == 3'b101) ? in5 :
               (sel == 3'b110) ? in6 :
               (sel == 3'b111) ? in7 : 1'b0;
endmodule

module mux8_8to1(
  input [7:0] in0,
  input [7:0] in1,
  input [7:0] in2,
  input [7:0] in3,
  input [7:0] in4,
  input [7:0] in5,
  input [7:0] in6,
  input [7:0] in7,
  input [2:0] sel,
  output [7:0] out
);
  assign out = (sel == 3'b000) ? in0 :
               (sel == 3'b001) ? in1 :
               (sel == 3'b010) ? in2 :
               (sel == 3'b011) ? in3 :
               (sel == 3'b100) ? in4 :
               (sel == 3'b101) ? in5 :
               (sel == 3'b110) ? in6 :
               (sel == 3'b111) ? in7 : 8'b00000000;

endmodule