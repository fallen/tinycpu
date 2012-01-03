module top;

parameter BOOTSTRAP = 2'd0;
parameter IDLE = 2'd1;
parameter PIPELINE_IS_ACKED = 2'd2;

reg 	clk = 0;
reg 	reset = 1;
wire 	pipeline_DOR;
reg 	ack_to_pipeline_reg = 0;
reg 	[7:0] data_in = 8'd0;
reg 	[7:0] data_out_reg = 8'd0;
reg 	pipeline_DIR;
wire 	[7:0] data_out;
reg 	[1:0] state = BOOTSTRAP;
wire 	[7:0] mem_do;

wire	[2:0] devices_mem_en;
wire	[7:0] device_1_mem_addr;
reg	[7:0] device_2_mem_addr = 8'd0;
reg	[7:0] device_3_mem_addr = 8'd0;
wire	[7:0] device_1_mem_di;
reg	[7:0] device_2_mem_di = 8'd0;
reg	[7:0] device_3_mem_di = 8'd0;
reg	[2:0] devices_mem_we = 3'd0;
wire	[2:0] devices_do_ack;
wire	mem_en;

reg	[7:0] PC = 8'd1;

always 	#5 clk = !clk;

assign 	ack_to_pipeline = ack_to_pipeline_reg;
assign	devices_mem_en[2:1] = 2'b00;

initial
begin
	$display("Starting Instruction Pipeline example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);

	#20
	reset = 0;

	# 100 $stop;
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


pipeline p(
	clk,
	reset,
	pipeline_DOR,
	pipeline_DIR,
	ack_to_pipeline,
	ack_from_pipeline,
	data_in,
	data_out,

	device_1_mem_addr,
	device_1_mem_di,
	devices_mem_en[0],
	devices_do_ack[0], 
	mem_do
);

always @(posedge clk)
begin
	if (reset)
	begin
		state <= BOOTSTRAP;
		ack_to_pipeline_reg <= 0;
		pipeline_DIR <= 0;
		data_in <= 0;
		PC <= 8'd1;
	end
	else
	begin
		case (state)

		BOOTSTRAP:
		begin
			data_in <= PC;
			state <= IDLE;
			ack_to_pipeline_reg <= 0;
			pipeline_DIR <= 1;
		end

		IDLE:
		begin
			if (pipeline_DOR)
			begin
				PC <= PC + 1;
				data_in <= PC + 1;
				pipeline_DIR <= 1;
				data_out_reg <= data_out;
				$display("Pipeline outputs %d", data_out);
				ack_to_pipeline_reg <= 1;
				state <= PIPELINE_IS_ACKED;
			end
			else
			begin
				state <= IDLE;
				pipeline_DIR <= 0;
				ack_to_pipeline_reg <= 0;
			end
		end

		PIPELINE_IS_ACKED:
		begin
			$display("We acked the pipeline");
			ack_to_pipeline_reg <= 0;
			pipeline_DIR <= 0;
			state <= IDLE;
		end

		endcase
	end
end

endmodule
