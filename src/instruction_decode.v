module instruction_decoder(
	input clk,
	input reset,
	/* Data Out Ready */
	output DOR,
	/* Data In Ready */
	input DIR,
	input ack_from_next,
	output ack_prev,
	input [31:0] data_in,
	output [31:0] data_out_instruction,
	output [31:0] data_out_S,
	output [31:0] data_out_T
);

/* values for the Finite State Machine of the decoder and executer */
parameter IDLE = 0;
parameter WAITING_ACK = 1;

reg state = IDLE;

parameter INST_TYPE_R = 2'd0;
parameter INST_TYPE_I = 2'd1;
parameter INST_TYPE_J = 2'd2;

reg [1:0] instruction_type = INST_TYPE_R;

reg [31:0] data_out_reg = 32'd0;
reg DOR_reg = 0;
reg ack_prev_reg = 0;
reg [31:0] instruction;
reg [31:0] D, S, T; /* registers for instruction execution */
reg [15:0] C; /* 16-bits immediate value */
reg [15:0] address;

reg [15:0] mem_addr_reg;
reg mem_we_reg;
reg mem_en_reg;
reg [31:0] mem_di_reg;
reg [3:0]  mem_bank_select_reg;

assign mem_addr = mem_addr_reg;
assign mem_di = mem_di_reg;
assign mem_we = mem_we_reg;
assign mem_en = mem_en_reg;
assign mem_bank_select = mem_bank_select_reg;

assign data_out = data_out_reg;
assign DOR = DOR_reg;
assign ack_prev = ack_prev_reg;

/* The MIPS32 registers */
reg [31:0] 	regs[31:0];
reg [31:0]	regs_do1;
reg [31:0]	regs_do2;
wire [31:0]	regs_di1;
wire [31:0]	regs_di2;
wire [4:0]	regs_index1;
wire [4:0]	regs_index2;
wire		regs_we1;
wire		regs_we2;
reg		regs_we1_reg;
reg		regs_we2_reg;
reg [4:0]	regs_index1_reg;
reg [4:0]	regs_index2_reg;

always @(posedge clk)
begin
	if ( ~reset )
	begin
		if (regs_we1)
			regs[ regs_index1 ] <= regs_di1;
		regs_do1 <= regs[ regs_index1 ];
	end
end

always @(posedge clk)
begin
	if ( ~reset )
	begin
		if (regs_we2)
			regs[ regs_index2 ] <= regs_di2;
		regs_do2 <= regs[ regs_index2 ];
	end
end

assign regs_index1 = regs_index1_reg;
assign regs_index2 = regs_index2_reg;
assign regs_we1 = regs_we1_reg;
assign regs_we2 = regs_we2_reg;

/* The decoder and executer FSM (Finite State Machine) */
always @(posedge clk)
begin
	if (reset)
	begin
		state <= IDLE;
		data_out_reg <= 0;
		DOR_reg <= 0;
		ack_prev_reg <= 0;
		mem_addr_reg <= 16'd0;
		mem_di_reg <= 32'd0;
		mem_en_reg <= 0;
		mem_we_reg <= 0;
		mem_bank_select_reg <= 4'b1111;
		regs_we1_reg <= 0;
		regs_we2_reg <= 0;
	end
	else
	begin
		case (state)

		IDLE:
		begin
			if (DIR)
			begin
				$display("instruction decoder receives input_data 0x%08X", data_in);
				ack_prev_reg <= 1;
				case ( data_in[31:26] )

				6'd0:
				begin
					regs_index1_reg <= data_in[25:21];
					regs_index2_reg <= data_in[20:16];
					C <= data_in[15:0];
					instruction_type <= INST_TYPE_R;
				end

				6'd2:
				begin
					instruction_type <= INST_TYPE_J;
				end

				6'd3:
				begin
					instruction_type <= INST_TYPE_J;
				end


				default:
				begin
					instruction_type <= INST_TYPE_I;
				end


				endcase
				state <= WAITING_ACK;
			end
		end

		WAITING_ACK:
		begin
			if (ack_from_next)
			begin
				$display("instruction decoder got ACK form next stage");
				DOR_reg <= 0;
				state <= IDLE;
			end
			else
			begin
				S <= regs_do1;
				T <= regs_do2;
				state <= WAITING_ACK;
				DOR_reg <= 1;
			end
			ack_prev_reg <= 0;
		end

		endcase
	end
end

endmodule
