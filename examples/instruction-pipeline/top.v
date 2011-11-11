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
reg mem_enable = 0;
wire [7:0] mem_do;
reg [7:0] mem_di = 8'd0;
reg [7:0] mem_addr = 8'd0;
reg mem_we = 0;

always #5 clk = !clk;

assign ack_to_pipeline = ack_to_pipeline_reg;

initial
begin
	$display("Starting Instruction Pipeline example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);

	$display("Testing RAM...");

	# 10 mem_enable = 1; /* We enable RAM block */

	# 10 mem_addr = 0;
	mem_di = 8'd64;
	mem_we = 1;
	$display("We write %d to address %d", mem_di, mem_addr);

	# 10 mem_addr = 1;
	mem_di = 8'd42;
	mem_we = 1;
	$display("We write %d to address %d", mem_di, mem_addr);

	# 10 mem_addr = 0;
	mem_we = 0;

	# 10 $display("We read %d at address %d", mem_do, mem_addr);

	mem_addr = 1;
	mem_we = 0;
	
	# 10 $display("We read %d at address %d", mem_do, mem_addr);

	$display("Done testing RAM, releasing RESET pin");
	reset = 0;

	# 100 $stop;
	$finish;
end

ram memory(clk, mem_enable, mem_addr, mem_di, mem_do, mem_we);
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
