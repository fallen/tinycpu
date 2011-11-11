all: top

run: all
	vvp top

top: top.v ram.v memory_controller.v
	iverilog -o $@ $^

clean:
	$(RM) -rf top

top.vcd: top
	$(MAKE) run

wave: top.vcd
	gtkwave top.vcd

.PHONY: all clean wave
