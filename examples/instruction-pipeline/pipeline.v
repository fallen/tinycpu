module pipeline(input clk, input reset, output DOR, input DIR, input ack_to_A, output ack_from_A, input [7:0] data_in, output [7:0] data_out_A);

wire DOR_A; /* Data Out Ready */
wire ack_to_A;

wire [7:0] data_out_A;

instruction_fetch IF (clk, reset, DOR_A, DIR, ack_to_A, ack_from_A, data_in, data_out_A);

endmodule
