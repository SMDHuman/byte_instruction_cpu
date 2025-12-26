test.vcd: cpu.out
	vvp cpu.out
cpu.out: cpu.v tester.v out.mem
	iverilog -o cpu.out tester.v cpu.v -g2012 

.PHONY: analyze
analyze: cpu.v

.PHONY: test
test: test.vcd
	gtkwave test.vcd	

test_program.mem: test_program.l
	lasm test_program.l -o test_program.mem -V -m diaroma

.PHONY: clean
clean: 
	rm -f cpu.out test.vcd test_program.mem