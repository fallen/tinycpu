all: top

run: all
	vvp top

top: top.v pipeline.v instruction_fetch.v ram.v
	iverilog -o $@ $^

clean:
	$(RM) -rf top

top.vcd: top
	$(MAKE) run

wave: top.vcd
	gtkwave top.vcd

.PHONY: all clean wave
