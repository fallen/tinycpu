`timescale 1ns/1ns
module top;

reg	clk = 0;
reg	reset = 1;

always #5 clk <= !clk;

reg	[2:0] devices_mem_en = 3'd0;
reg	[7:0] device_1_mem_addr = 7'd0;
reg	[7:0] device_2_mem_addr = 7'd0;
reg	[7:0] device_3_mem_addr = 7'd0;
reg	[7:0] device_1_mem_di = 7'd0;
reg	[7:0] device_2_mem_di = 7'd0;
reg	[7:0] device_3_mem_di = 7'd0;
reg	[2:0] devices_mem_we = 3'd0;
wire	[2:0] devices_do_ack;
wire	[7:0] mem_do;

initial
begin
	$display("Starting memory_controller example");
/*	$monitor("devices_do_ack == %b at %0d", devices_do_ack, $time); */
	$dumpfile("top.vcd");
	$dumpvars(0, top);
	# 10 reset <= 0;

	/* All 3 slaves are issuing parallel READ */
	# 10
	device_1_mem_addr = 7'd5;
	device_2_mem_addr = 7'd7;
	device_3_mem_addr = 7'd9;
	devices_mem_en = 3'b111;

	/* Suddenly slave 1 stops accessing SRAM */
	# 60
	devices_mem_en = 3'b101;

	/* Then all 3 slaves are issuing parallel WRITE */
	# 60
	device_1_mem_addr = 7'h0A;
	device_2_mem_addr = 7'h0B;
	device_3_mem_addr = 7'h0C;
	device_1_mem_di = 7'd42;
	device_2_mem_di = 7'd43;
	device_3_mem_di = 7'd44;
	devices_mem_we = 3'b111;
	devices_mem_en = 3'b111;

	# 60
	devices_mem_we = 3'd0;
	devices_mem_en = 3'b001;

	# 20
	devices_mem_en = 3'b001;

	# 20
	devices_mem_en = 3'b010;

	# 20
	devices_mem_en = 3'b100;

	# 20 $stop;
	$finish;
end

memory_controller mem_cont(clk,
			   reset,
			   devices_mem_en,
			   device_1_mem_addr,
			   device_2_mem_addr,
			   device_3_mem_addr,
			   device_1_mem_di,
			   device_2_mem_di,
			   device_3_mem_di,
			   devices_mem_we,
			   devices_do_ack,
			   mem_do);

always @(posedge clk)
begin
	if (devices_do_ack[0])
		$display("Device_1's transaction done, mem_do = %d, devices_do_ack = %b", mem_do, devices_do_ack);
	else if (devices_do_ack[1])
		$display("Device_2's transaction done, mem_do = %d, devices_do_ack = %b", mem_do, devices_do_ack);
	else if (devices_do_ack[2])
		$display("Device_3's transaction done, mem_do = %d, devices_do_ack = %b", mem_do, devices_do_ack);
	else
		$display("WHAT ?! devices_do_ack = %b", devices_do_ack);
end

endmodule
