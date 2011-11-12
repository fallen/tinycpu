module top;

reg	clk = 0;
reg	reset = 1;

always #5 clk = !clk;

reg	[1:0] devices_mem_en = 2'd0;
reg	[7:0] device_1_mem_addr = 7'd0;
reg	[7:0] device_2_mem_addr = 7'd0;
reg	[7:0] device_1_mem_di = 7'd0;
reg	[7:0] device_2_mem_di = 7'd0;
reg	[1:0] devices_mem_we = 2'd0;
wire	[7:0] mem_do;

initial
begin
	$display("Starting memory_controller example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);
	# 10 reset = 0;

	/* Both slaves are issuing parallel READ */
	device_1_mem_addr = 7'd0;
	device_2_mem_addr = 7'd1;
	devices_mem_en = 2'b11;
	

	# 200 $stop;
	$finish;
end

memory_controller mem_cont(clk, 
			   devices_mem_en, 
			   device_1_mem_addr, 
			   device_2_mem_addr, 
			   device_1_mem_di, 
			   device_2_mem_di, 
			   devices_mem_we, 
			   mem_do);


endmodule
