all: top ram0.data ram1.data ram2.data ram3.data

run: all
	vvp top

top: top.v pipeline.v instruction_fetch.v ram.v memory_controller.v instruction_decode.v
	iverilog -o $@ $^

%.data: genram
	./genram
	chmod 640 ram*.data

genram: genram.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	$(RM) -rf top genram

top.vcd: top
	$(MAKE) run

wave: top.vcd
	gtkwave top.vcd

.PHONY: all clean wave
