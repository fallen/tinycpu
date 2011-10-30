module top;

parameter IDLE = 1'd0;
parameter PIPELINE_IS_ACKED = 1'd1;

reg clk = 0;
reg reset = 1;
wire pipeline_DOR;
reg ack_to_pipeline_reg = 0;
reg [7:0] data_in = 8'd42;
reg [7:0] data_out_reg = 8'd0;
reg pipeline_DIR;
wire [7:0] data_out;
reg state = IDLE;

always #5 clk = !clk;

assign ack_to_pipeline = ack_to_pipeline_reg;

initial
begin
	$display("Starting pipeline example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);
	# 10 reset = 0;
	# 20 pipeline_DIR = 1;
	# 30 pipeline_DIR = 0;
	# 200 $stop;
	$finish;
end

pipeline p(clk, reset, pipeline_DOR, pipeline_DIR, ack_to_pipeline, ack_from_pipeline, data_in, data_out);

always @(posedge clk)
begin
	if (reset)
	begin
		state <= IDLE;
		ack_to_pipeline_reg <= 0;
	end
	else
	begin
		case (state)

		IDLE:
		begin
			if (pipeline_DOR)
			begin
				data_out_reg <= data_out;
				$display("Pipeline outputs %d", data_out);
				ack_to_pipeline_reg <= 1;
				state <= PIPELINE_IS_ACKED;
			end
			else
			begin
				state <= IDLE;
				ack_to_pipeline_reg <= 0;
			end
		end

		PIPELINE_IS_ACKED:
		begin
			$display("We acked the pipeline");
			ack_to_pipeline_reg <= 0;
			state <= IDLE;
		end

		endcase
	end
end

endmodule
