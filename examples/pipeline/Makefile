all: top

top: top.v pipeline.v stage_A.v stage_B.v stage_C.v
	iverilog -o $@ $^

clean:
	$(RM) -rf top

.PHONY: all clean
