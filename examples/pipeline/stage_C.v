module stage_C(input clk, input reset, output DOR, input DIR, input ack_from_next, output ack_prev, input [7:0] data_in, output [7:0] data_out);

parameter IDLE = 1'd0;
parameter WAITING_ACK = 1'd1;

reg state = IDLE;
reg [7:0] data_out_reg = 8'd0;
reg DOR_reg = 0;
reg ack_prev_reg = 0;
reg [7:0] data_in_buffer;

assign data_out = data_out_reg;
assign DOR = DOR_reg;
assign ack_prev = ack_prev_reg;

always @(posedge clk)
begin
	if (reset)
	begin
		state <= IDLE;
		data_out_reg <= 0;
		DOR_reg <= 0;
		ack_prev_reg <= 0;
	end
	else
	begin
		case (state)

		IDLE:
		begin
			if (DIR)
			begin
				$display("stage_C receives input_data %d", data_in);
				state <= WAITING_ACK;
				ack_prev_reg <= 1;
				DOR_reg <= 1;
			end
			data_in_buffer <= data_in;
			data_out_reg <= data_in + 1;
		end

		WAITING_ACK:
		begin
			if (ack_from_next)
			begin
				$display("stage_C got ACK form stage_B");
				DOR_reg <= 0;
				data_out_reg <= 0;
				state <= IDLE;
			end
			else
			begin
				$display("stage_C waits for ACK from stage_B");
				state <= WAITING_ACK;
				data_out_reg <= data_in + 1;
				DOR_reg <= 1;
			end
			
			ack_prev_reg <= 0;
		end

		endcase
	end
end

endmodule
