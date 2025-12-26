#define FAKE_CPU81_IMPLEMENTATION
#include "fake_cpu81.h"
#include <stdio.h>

uint8_t rom[1<<16] = {0};

void out_callback(uint8_t port, uint8_t data);
uint8_t read_rom(uint16_t address);

int main(){
  cpu81_state_t cpu;
  cpu81_reset(&cpu);

  cpu.read_rom = read_rom;
  cpu.out_callback = out_callback;

  FILE* input = fopen("../py_assembler/a.out", "r");
  fread(rom, 1, 1<<16, input);

  int count_steps = 0;
  while(!cpu.halt){
    cpu81_step(&cpu);
    count_steps++;
  }
  printf("RAM[0-31]: ");
  for(int i = 0; i < 32; i++){
      printf("%d, ", cpu.ram[i]);
  }
  printf("\n");
  printf("Total steps: %d\n", count_steps);
  return 0; 
  return 0;
}

void out_callback(uint8_t port, uint8_t data){
    printf("Output to port %d: %d\n", port, data);
}

uint8_t read_rom(uint16_t address){
  return rom[address];
}