module pipeline(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_to_pipeline,
	output ack_from_pipeline,
	input [31:0] data_in,
	output [31:0] data_out,

	output [9:0] device_1_mem_addr,
	output [31:0] device_1_mem_di,
	output [9:0] device_2_mem_addr,
	output [31:0] device_2_mem_di,
	output [1:0] devices_burst_en,
	output [1:0] devices_mem_we, 
	output [1:0] devices_mem_en, 
	input [1:0] devices_do_ack, 


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

assign devices_mem_we[0] = 0;

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
	devices_mem_en[0], 
	device_1_mem_addr,
	mem_do, 
	devices_do_ack[0]
);

instruction_decoder ID (
	clk,
	reset,
	DOR_ID,
	DIR_ID,
	ack_to_ID,
	ack_from_ID,
	data_in_ID,
	data_out_ID,

	device_2_mem_di,
	devices_mem_en[1],
	device_2_mem_addr,
	devices_mem_we[1],
	mem_do,
	devices_do_ack[1]
);

endmodule
