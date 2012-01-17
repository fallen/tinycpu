module pipeline(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_to_pipeline,
	output ack_from_pipeline,
	input [31:0] data_in,
	output [31:0] data_out,

	output [15:0] device_1_mem_addr,
	output [31:0] device_1_mem_di,
	output [15:0] device_2_mem_addr,
	output [31:0] device_2_mem_di,
	output [3:0]  device_2_bank_select,
	output [1:0] devices_burst_en,
	output [1:0] devices_mem_we, 
	output [1:0] devices_mem_en, 
	input [1:0] devices_do_ack, 

	input [31:0] mem_do
);

/* No burst access to ram allowed for now */
assign device_1_burst_en = 0;

assign device_1_mem_di = 32'd0;

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
wire [31:0] data_out_instruction_ID;
wire [31:0] data_out_S_ID;
wire [31:0] data_out_T_ID;

wire [31:0] data_in_EX;
wire [31:0] data_out_EX;

assign DIR_IF = DIR;
assign DIR_ID = DOR_IF;
assign DIR_EX = DOR_ID;
assign DOR = DOR_EX; 

assign data_in_IF = data_in;
assign data_in_ID = data_out_IF;

assign data_in_instruction_EX = data_out_instruction_ID;
assign data_in_S_EX = data_out_S_ID;
assign data_in_T_EX = data_out_T_ID;

assign data_out = data_out_EX;

assign ack_from_pipeline = ack_from_IF;
assign ack_to_EX = ack_to_pipeline;
assign ack_to_ID = ack_from_EX;
assign ack_to_IF = ack_from_ID;

assign devices_mem_we[0] = 0;

wire [31:0] icache_do;
wire [31:0] dcache_do;
wire [15:0] if_addr;
wire [15:0] ex_addr;
wire if_en;
wire if_ack;
wire ex_en;
wire ex_ack;

icache i_cache(
	clk,
	reset,

	if_addr,
	if_en,
	icache_do,
	if_ack,

	device_1_mem_addr,
	devices_mem_en[0],
	devices_do_ack[0],
	mem_do
);

instruction_fetch IF (
	clk,
	reset,
	DOR_IF,
	DIR_IF,
	ack_to_IF,
	ack_from_IF,
	data_in_IF,
	data_out_IF,
	
	if_en, 
	if_addr,
	icache_do, 
	if_ack
);

instruction_decoder ID (
	clk,
	reset,
	DOR_ID,
	DIR_ID,
	ack_to_ID,
	ack_from_ID,
	data_in_ID,
	data_out_instruction_ID,
	data_out_S_ID,
	data_out_T_ID
);

dcache d_cache(
	clk,
	reset,

	ex_addr,
	ex_en,
	ex_we,
	dcache_do,
	ex_ack,

	device_2_mem_addr,
	devices_mem_en[1],
	devices_mem_we[1],
	device_2_mem_di,
	devices_do_ack[1],
	mem_do
);

instruction_executer EX (
	clk,
	reset,
	DOR_EX,
	DIR_EX,
	ack_to_EX,
	ack_from_EX,
	data_in_EX,
	data_out_EX,

	ex_en,
	ex_addr,
	dcache_do,
	ex_ack
);

endmodule
