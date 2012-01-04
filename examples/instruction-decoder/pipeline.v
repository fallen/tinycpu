module pipeline(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_to_pipeline,
	output ack_from_pipeline,
	input [31:0] data_in,
	output [31:0] data_out,

	output [31:0] device_1_mem_addr,
	output [31:0] device_1_mem_di,
	output device_1_burst_en,
	output device_1_mem_en, 
	input device_1_do_ack, 
	input [31:0] mem_do
);

/* No burst access to ram allowed for now */
assign device_1_burst_en = 0;

wire DOR_IF; /* Data Out Ready */
wire DIR_IF;

wire ack_to_IF;
wire ack_from_IF;

wire ack_to_ID;
wire ack_from_ID;

wire DOR_ID;
wire DIR_ID;

wire [31:0] data_in_ID;
wire [31:0] data_out_ID;

wire [31:0] data_in_IF;
wire [31:0] data_out_IF;

assign DIR_IF = DIR;
assign DIR_ID = DOR_IF;

assign DOR = DOR_ID; 

assign data_in_IF = data_in;
assign data_in_ID = data_out_IF;

assign data_out = data_out_ID;

assign ack_from_pipeline = ack_from_IF;
assign ack_to_ID = ack_to_pipeline;

assign ack_to_IF = ack_from_ID;

instruction_fetch IF (
	clk,
	reset,
	DOR_IF,
	DIR_IF,
	ack_to_IF,
	ack_from_IF,
	data_in_IF,
	data_out_IF,
	
	device_1_mem_di,
	device_1_mem_en, 
	device_1_mem_addr,
	mem_do, 
	device_1_do_ack
);

instruction_decoder ID (
	clk,
	reset,
	DOR_ID,
	DIR_ID,
	ack_to_ID,
	ack_from_ID,
	data_in_ID,
	data_out_ID
);

endmodule
