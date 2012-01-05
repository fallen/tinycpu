module instruction_decoder(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_from_next,
	output ack_prev,
	input [31:0] data_in,
	output [31:0] data_out
);

parameter IDLE = 7'd0;
parameter WAITING_ACK = 7'd1;
parameter FETCH_REGISTERS = 7'd2;
parameter INST_ADD = 7'd3;
parameter INST_ADDU = 7'd4;
parameter INST_SUB = 7'd5;
parameter INST_ADDI = 7'd6;

reg [6:0] state = IDLE;

parameter INST_TYPE_R = 2'd0;
parameter INST_TYPE_I = 2'd1;
parameter INST_TYPE_J = 2'd2;

reg [1:0] instruction_type = INST_TYPE_R;

reg [31:0] data_out_reg = 32'd0;
reg DOR_reg = 0;
reg ack_prev_reg = 0;
reg [31:0] instruction;
reg [6:0] instruction_state;
reg [31:0] D, S, T; /* registers for instruction execution */

assign data_out = data_out_reg;
assign DOR = DOR_reg;
assign ack_prev = ack_prev_reg;

reg [31:0] 	REG_AT, 
		REG_V0,
		REG_V1,
		REG_A0,
		REG_A1,
		REG_A2,
		REG_A3,
		REG_T0,
		REG_T1,
		REG_T2,
		REG_T3,
		REG_T4,
		REG_T5,
		REG_T6,
		REG_T7,
		REG_S0,
		REG_S1,
		REG_S2,
		REG_S3,
		REG_S4,
		REG_S5,
		REG_S6,
		REG_S7,
		REG_T8,
		REG_T9,
		REG_K0,
		REG_K1,
		REG_GP,
		REG_SP,
		REG_FP,
		REG_RA;

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
				$display("instruction decoder receives input_data %d", data_in);
				state <= WAITING_ACK;
				ack_prev_reg <= 1;
				DOR_reg <= 1;
				instruction <= data_in;
				if (data_in[31:27] == 6'd0)
				begin
					/* if instruction[31:27] == 000000 then it's a type R instruction */
					case (data_in[5:0])
					/* add $d,$s,$t */
					6'h20:
					begin
						instruction_state <= INST_ADD;
					end

					/* addu $d,$s,$t */
					6'h21:
					begin
						instruction_state <= INST_ADDU;
					end

					/* sub $d,$s,$t */
					6'h22:
					begin
						instruction_state <= INST_SUB;
					end
					endcase
					state <= FETCH_REGISTERS;
					instruction_type <= INST_TYPE_R;
				end
				else
				begin
					case (data_in[31:27])
					/*
					*  Most instructions here are type I except two type J.
					*  since type J does not need to fetch any register, 
					*  let's flag every instruction as type I and process
					*  type J instructions directly without going through the
					*  FETCH_REGISTERS state of the FSM.
					*/

					/* addi $t,$s,C */
					6'h8:
					begin
						instruction_state <= INST_ADDI;
						state <= FETCH_REGISTERS;
					end
					endcase
					instruction_type <= INST_TYPE_I;
				end
			end
		end

		FETCH_REGISTERS:
		begin
			if (instruction_type == INST_TYPE_R)
			begin
				case (data_in[25:21])

				/* $zero (aka $0) is constant 0 */				
				5'd0:	S <= 32'd0;
				/* $at (aka $1) is assembler temporary */
				5'd1:	S <= REG_AT;
				/* $v0 and $v1 (aka $2 an $3) are values for function returns and expression evaluation */
				5'd2:	S <= REG_V0;
				5'd3:	S <= REG_V1;
				/* $a0 to $a3 (aka $4 to $7) are function argument registers */
				5'd4:	S <= REG_A0;
				5'd5:	S <= REG_A1;
				5'd6:	S <= REG_A2;
				5'd7:	S <= REG_A3;
				/* $t0 to $t7 (aka $8 to $15) are temporary registers */
				5'd8:	S <= REG_T0;
				5'd9:	S <= REG_T1;
				5'd10:	S <= REG_T2;
				5'd11:	S <= REG_T3;
				5'd12:	S <= REG_T4;
				5'd13:	S <= REG_T5;
				5'd14:	S <= REG_T6;
				5'd15:	S <= REG_T7;
				/* $s0 to $7 (aka $16 to $23) are saved temporary registers */
				5'd16:	S <= REG_S0;
				5'd17:	S <= REG_S1;
				5'd18:	S <= REG_S2;
				5'd19:	S <= REG_S3;
				5'd20:	S <= REG_S4;
				5'd21:	S <= REG_S5;
				5'd22:	S <= REG_S6;
				5'd23:	S <= REG_S7;
				/* $t8 and $t9 (aka $24 and $25) are temporary registers */
				5'd24:	S <= REG_T8;
				5'd25:	S <= REG_T9;
				/* $k0 and $k1 (aka $26 and $27) are reserved for OS kernel */
				5'd26:	S <= REG_K0;
				5'd27:	S <= REG_K1;
				/* $gp (aka $28) is global pointer register */
				5'd28:	S <= REG_GP;
				/* $sp (aka $29) is stack pointer register */
				5'd29:	S <= REG_SP;
				/* $fp (aka $30) is frame pointer register */
				5'd30:	S <= REG_FP;
				/* $ra (aka $31) is return address register */
				5'd31:	S <= REG_RA;
					

				endcase
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
				state <= WAITING_ACK;
				DOR_reg <= 1;
			end
			
			data_out_reg <= data_in + 1;
			ack_prev_reg <= 0;
		end

		endcase
	end
end

endmodule
