yosys -p "read_verilog cpu.v; synth -top cpu" > yosys_${TOP}.log
