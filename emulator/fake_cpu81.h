#ifndef FAKE_CPU81_H
#define FAKE_CPU81_H

#include <stdio.h>
#include <stdint.h>
#include <string.h>

typedef struct{
	// Registers
	uint8_t a;
	uint8_t b;
	uint8_t x;
	uint16_t pc;
	uint8_t halt;
	uint8_t out[16];
	uint8_t inp[16];
	void (*out_callback)(uint8_t port, uint8_t data);
	// Condition testing flags
	uint8_t zero_flag;
	uint8_t minus_flag;
	uint8_t carry_flag;
	// Memory access
  uint8_t (*read_rom)(uint16_t address);
  uint8_t ram[256];
}cpu81_state_t;

#ifdef FAKE_CPU81_IMPLEMENTATION
// True: execute instruction, False: skip instruction
static uint8_t test_flags(uint8_t operand, cpu81_state_t* cpu){
	if(operand == 0) return 1; // Always
	uint8_t result = 1;
	if((operand & 0b0001) && !(cpu->zero_flag)) result = 0; 
	if((operand & 0b0010) && !(cpu->minus_flag)) result = 0; 
	if((operand & 0b0100) && !(cpu->carry_flag)) result = 0; 
	if(operand & 0b1000) result = !result; // I
	return result;
}
void cpu81_reset(cpu81_state_t* cpu){
    cpu->a = 0;
    cpu->b = 0;
    cpu->x = 0;
    cpu->pc = 0;
    cpu->carry_flag = 0;
    cpu->zero_flag = 0;
    cpu->minus_flag = 0;
		cpu->halt = 0;
    memset(cpu->out, 0, 16);
    memset(cpu->inp, 0, 16);
    memset(cpu->ram, 0, 256);
}

void cpu81_step(cpu81_state_t* cpu){
  if(!cpu->read_rom) printf("[WARNING] read_rom not defined");
	if(cpu->halt) return;
	uint8_t instruction = cpu->read_rom(cpu->pc);
	cpu->pc++;
	uint8_t opcode = (instruction >> 4) & 0x0F;
	uint8_t operand = instruction & 0x0F;
	if(test_flags(operand, cpu) || (opcode == 0x6 || opcode == 0x7 || opcode == 0x5)) {
		switch(opcode){
			case 0x00:{ // TAB
				cpu->b = cpu->a;
				break;}
			case 0x01:{ // SAX
				uint8_t tmp = cpu->a;
				cpu->a = cpu->x;
				cpu->x = tmp;
			break;}
			case 0x02:{ // STA
				cpu->ram[cpu->b] = cpu->a;
			break;}
			case 0x03:{ // LDA
				cpu->a = cpu->ram[cpu->b];
			break;}
			case 0x04:{ // JMP
				cpu->pc = (uint16_t)(cpu->a | (cpu->b << 8));
			break;}
			case 0x05:{ // PHA
				cpu->a = ((cpu->a << 4) & 0xf0) | operand;
			break;}
			case 0x06:{ // OUT
				cpu->out[operand] = cpu->a;
				if(cpu->out_callback) cpu->out_callback(operand, cpu->a);
			break;}
			case 0x07:{ // INP
				cpu->a = cpu->out[operand];
			break;}
			case 0x08:{ // ADD
				if((uint16_t)(cpu->a + cpu->b) > 255) cpu->carry_flag = 1;
				else cpu->carry_flag = 0;
				cpu->a += cpu->b;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x09:{ // SUB
				if((uint16_t)(cpu->a - cpu->b) > 255) cpu->carry_flag = 1;
				else cpu->carry_flag = 0;
				cpu->a -= cpu->b;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0A:{ // INC
				if((uint16_t)(cpu->a + 1) > 255) cpu->carry_flag = 1;
				else cpu->carry_flag = 0;
				cpu->a += 1;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0B:{ // DEC
				if((uint16_t)(cpu->a - 1) > 255) cpu->carry_flag = 1;
				else cpu->carry_flag = 0;
				cpu->a -= 1;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0C:{ // AND
				cpu->a &= cpu->b;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0D:{ // ORA
				cpu->a |= cpu->b;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0E:{ // XOR
				cpu->a ^= cpu->b;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
			case 0x0F:{ // NOT
				cpu->a = ~cpu->a;
				cpu->zero_flag = (cpu->a == 0);
				cpu->minus_flag = (cpu->a & 0x80) != 0;
			break;}
		}
	}
	if(cpu->pc == 0xFFFF) cpu->halt = 1;
}
#endif // CPU81_IMPLEMENTATION
#endif // FAKE_CPU81_H