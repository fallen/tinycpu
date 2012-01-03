module pipeline(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_to_A,
	output ack_from_A,
	input [7:0] data_in,
	output [7:0] data_out_A,

	output [7:0] device_1_mem_addr,
	output [7:0] device_1_mem_di,
	output device_1_mem_en, 
	input device_1_do_ack, 
	input [7:0] mem_do
);

wire DOR_A; /* Data Out Ready */
wire ack_to_A;

assign DOR = DOR_A;
assign DIR_A = DIR;

wire [7:0] data_out_A;

instruction_fetch IF (
	clk,
	reset,
	DOR_A,
	DIR,
	ack_to_A,
	ack_from_A,
	data_in,
	data_out_A,
	
	device_1_mem_di,
	device_1_mem_en, 
	device_1_mem_addr,
	mem_do, 
	device_1_do_ack
	);

endmodule
