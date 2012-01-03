all: top ram.data

run: all
	vvp top

top: top.v ram.v memory_controller.v
	iverilog -o $@ $^

ram.data: genram
	./genram > ram.data

genram: genram.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	$(RM) -rf top genram ram.data

top.vcd: top
	$(MAKE) run

wave: top.vcd
	gtkwave top.vcd

.PHONY: all clean wave
