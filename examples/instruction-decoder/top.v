module top;

parameter WAITING_ACK_FROM_PIPELINE = 0;
parameter PIPELINE_ACKED = 1;

parameter WAITING_DOR_FROM_PIPELINE = 0;
parameter PIPELINE_IS_ACKED = 1;

reg 	clk = 0;
reg 	reset = 1;
wire 	pipeline_DOR;
reg 	ack_to_pipeline_reg = 0;
reg 	[31:0] data_in = 32'd0;
reg 	[31:0] data_out_reg = 32'd0;
reg 	pipeline_DIR;
wire 	[31:0] data_out;
reg 	state = WAITING_ACK_FROM_PIPELINE;
reg	ack_state = WAITING_DOR_FROM_PIPELINE;
wire 	[31:0] mem_do;

wire	[2:0] devices_mem_en;
wire	[2:0] devices_burst_en;
wire	[9:0] device_1_mem_addr;
wire	[9:0] device_2_mem_addr;
reg	[9:0] device_3_mem_addr = 9'd0;
wire	[31:0] device_1_mem_di;
wire	[31:0] device_2_mem_di;
reg	[31:0] device_3_mem_di = 32'd0;
wire	[2:0] devices_mem_we;
wire	[2:0] devices_do_ack;
wire	mem_en;

reg	[31:0] PC = 32'd0;

always 	#5 clk = !clk;

assign 	ack_to_pipeline = ack_to_pipeline_reg;
assign	devices_mem_en[2] = 0;
assign	devices_burst_en[2] = 0;
assign	devices_mem_we[2] = 0;
assign	devices_do_ack[2] = 0;

initial
begin
	$display("Starting Instruction Pipeline example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);

	#20
	reset = 0;

	# 350 $stop;
	$finish;
end

memory_controller mem_cont(clk,
			   reset,
			   devices_burst_en,
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
	device_2_mem_addr,
	device_2_mem_di,
	devices_burst_en[1:0],
	devices_mem_we[1:0], 
	devices_mem_en[1:0],
	devices_do_ack[1:0], 
	mem_do
);

always @(posedge clk)
begin
	if (reset)
	begin
		state <= WAITING_ACK_FROM_PIPELINE;
		ack_to_pipeline_reg <= 0;
		pipeline_DIR <= 0;
		data_in <= 0;
		PC <= 32'd0;
	end
	else
	begin
		case (state)

		WAITING_ACK_FROM_PIPELINE:
		begin
			if (ack_from_pipeline)
			begin
				pipeline_DIR <= 0;
				PC <= PC + 4;
				state <= PIPELINE_ACKED;
			end
			else
			begin
				data_in <= PC;
				pipeline_DIR <= 1;
				state <= WAITING_ACK_FROM_PIPELINE;
			end
		end

		PIPELINE_ACKED:
		begin
			if (ack_from_pipeline)
			begin
				state <= PIPELINE_ACKED;
			end
			else
			begin
				state <= WAITING_ACK_FROM_PIPELINE;
			end
			pipeline_DIR <= 0;
		end
		


		endcase
	end
end

always @(posedge clk)
begin

	case (ack_state)
	
	WAITING_DOR_FROM_PIPELINE:
	begin
		if (pipeline_DOR)
		begin
			data_out_reg <= data_out;
			$display("Pipeline outputs %d", data_out);
			ack_to_pipeline_reg <= 1;
			ack_state <= PIPELINE_IS_ACKED;
		end
		else
		begin
			ack_state <= WAITING_DOR_FROM_PIPELINE;
			ack_to_pipeline_reg <= 0;
		end
	end

	PIPELINE_IS_ACKED:
	begin
		$display("We acked the pipeline");
		ack_to_pipeline_reg <= 0;
		ack_state <= WAITING_DOR_FROM_PIPELINE;
	end
	endcase
end

endmodule
