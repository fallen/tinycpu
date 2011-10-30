module pipeline(input clk, input reset, output DOR, input DIR, input ack_to_C, output ack_from_A, input [7:0] data_in, output [7:0] data_out);

wire DOR_A; /* Data Out Ready */
wire DOR_B;

wire DIR_B; /* Data In Ready */
wire DIR_C;

wire ack_to_A;
wire ack_to_B;
wire ack_from_B;
wire ack_from_C;

wire [7:0] data_out_A;
wire [7:0] data_out_B;

wire [7:0] data_in_B;
wire [7:0] data_in_C;

assign DIR_B = DOR_A;
assign DIR_C = DOR_B;

assign data_in_B = data_out_A;
assign data_in_C = data_out_B;

assign ack_to_A = ack_from_B;
assign ack_to_B = ack_from_C;

stage_A sA (clk, reset, DOR_A, DIR, ack_to_A, ack_from_A, data_in, data_out_A);
stage_B sB (clk, reset, DOR_B, DIR_B, ack_to_B, ack_from_B, data_in_B, data_out_B);
stage_C sC (clk, reset, DOR, DIR_C, ack_to_C, ack_from_C, data_in_C, data_out);

endmodule
