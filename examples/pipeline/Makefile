all: top

run: all
	vvp top

top: top.v pipeline.v stage_A.v stage_B.v stage_C.v
	iverilog -o $@ $^

clean:
	$(RM) -rf top top.vcd

top.vcd: top
	$(MAKE) run

wave: top.vcd
	gtkwave top.vcd

.PHONY: all clean wave run
