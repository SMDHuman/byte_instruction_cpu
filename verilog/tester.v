module tester();
  reg clk;
  reg rst;
  wire [15:0] address;
  reg [7:0] mem [0:4128];
  wire [7:0] mem_out = mem[address];
  wire [7:0] cpu_out;
  wire io_output;

  cpu cpu_instance (
    .clk(clk),
    .rst(rst),
    .rom_address(address),
    .rom_data(mem_out),
    .io_sel(),
    .io_data(cpu_out),
    .io_reading(),
    .io_output(io_output)
  );
  initial begin 
    $dumpfile("test.vcd");
    $dumpvars(0, tester);
    $readmemh("out.mem", mem, 0, 494);
  end


  initial begin 
    rst = 0;
    clk = 0;
    #0 rst = 1;
    #4 rst = 0;
    //#10000 $finish;
  end
  always #1 clk = ~clk;
  always @ (posedge clk) begin
    if(address == 16'hFFFF) $finish;
  end
  always @ (posedge io_output) begin
    $display("output: %h", cpu_out);
    // You can add monitoring code here if needed
  end

endmodule