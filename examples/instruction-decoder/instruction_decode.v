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
	output [31:0] data_out,

	output [31:0] mem_di, 
	output mem_en, 
	output [3:0] mem_bank_select,
	output [9:0] mem_addr, 
	output mem_we, 
	input [31:0] mem_do, 
	input mem_do_ack
);

/* values for the Finite State Machine of the decoder and executer */
parameter IDLE = 7'd0;
parameter WAITING_ACK = 7'd1;
parameter FETCH_REGISTERS = 7'd2;
parameter INST_ADD = 7'd3;
parameter INST_ADDU = 7'd4;
parameter INST_SUB = 7'd5;
parameter INST_ADDI = 7'd6;
parameter INST_SUBU = 7'd7;
parameter INST_AND = 7'd8;
parameter INST_OR = 7'd9;
parameter INST_XOR = 7'd10;
parameter INST_NOR = 7'd11;
parameter INST_SLT = 7'd12;
parameter INST_SLL = 7'd13;
parameter INST_SRL = 7'd14;
parameter INST_SRA = 7'd15;
parameter INST_LD = 7'd16;
parameter FETCH_FROM_MEM = 7'd17;
parameter FETCH_FROM_MEM_WAIT_ACK = 7'd18;
parameter STORE_TO_MEM = 7'd19;
parameter STORE_TO_MEM_WAIT_ACK = 7'd20;
parameter WRITE_BACK = 7'd21;

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
reg memory_load;
reg signed_load;
reg [3:0] access_width;
reg [31:0] D, S, T; /* registers for instruction execution */
reg [15:0] C; /* 16-bits immediate value */
reg [15:0] address;

reg [9:0] mem_addr_reg;
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
reg [31:0] 	REG_AT = 32'd0, 
		REG_V0 = 32'd0,
		REG_V1 = 32'd0,
		REG_A0 = 32'd0,
		REG_A1 = 32'd0,
		REG_A2 = 32'd0,
		REG_A3 = 32'd0,
		REG_T0 = 32'd0,
		REG_T1 = 32'd0,
		REG_T2 = 32'd0,
		REG_T3 = 32'd0,
		REG_T4 = 32'd0,
		REG_T5 = 32'd0,
		REG_T6 = 32'd0,
		REG_T7 = 32'd0,
		REG_S0 = 32'd0,
		REG_S1 = 32'd0,
		REG_S2 = 32'd0,
		REG_S3 = 32'd0,
		REG_S4 = 32'd0,
		REG_S5 = 32'd0,
		REG_S6 = 32'd0,
		REG_S7 = 32'd0,
		REG_T8 = 32'd0,
		REG_T9 = 32'd0,
		REG_K0 = 32'd0,
		REG_K1 = 32'd0,
		REG_GP = 32'd0,
		REG_SP = 32'd0,
		REG_FP = 32'd0,
		REG_RA = 32'd0;

/* The decoder and executer FSM (Finite State Machine) */
always @(posedge clk)
begin
	if (reset)
	begin
		state <= IDLE;
		data_out_reg <= 0;
		DOR_reg <= 0;
		ack_prev_reg <= 0;
		mem_addr_reg <= 10'd0;
		mem_di_reg <= 32'd0;
		mem_en_reg <= 0;
		mem_we_reg <= 0;
		signed_load <= 0;
		mem_bank_select_reg <= 4'b1111;
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
				instruction <= data_in;
				if (data_in[31:26] == 6'd0)
				begin
					/* if instruction[31:27] == 000000 then it's a type R instruction */
					case (data_in[5:0])

					/* sll $d,$t,shamt*/
					6'd0:
					begin
						$display("We decode instruction : sll");
						instruction_state <= INST_SLL;
					end

					/* srl $d,$t,shamt*/
					6'd2:
					begin
						$display("We decode instruction : srl");
						instruction_state <= INST_SRL;
					end

					/* sra $d,$t,shamt*/
					6'd3:
					begin
						$display("We decode instruction : sra");
						instruction_state <= INST_SRA;
					end

					/* add $d,$s,$t */
					6'h20:
					begin
						$display("We decode instruction : add");
						instruction_state <= INST_ADD;
					end

					/* addu $d,$s,$t */
					6'h21:
					begin
						$display("We decode instruction : addu");
						instruction_state <= INST_ADDU;
					end

					/* sub $d,$s,$t */
					6'h22:
					begin
						$display("We decode instruction : sub");
						instruction_state <= INST_SUB;
					end

					/* subu $d,$s,$t */
					6'h23:
					begin
						$display("We decode instruction : subu");
						instruction_state <= INST_SUBU;
					end

					/* and $d,$s,$t */
					6'h24:
					begin
						$display("We decode instruction : and");
						instruction_state <= INST_AND;
					end

					/* or $d,$s,$t */
					6'h25:
					begin
						$display("We decode instruction : or");
						instruction_state <= INST_OR;
					end

					/* xor $d,$s,$t */
					6'h26:
					begin
						$display("We decode instruction : xor");
						instruction_state <= INST_XOR;
					end

					/* nor $d,$s,$t */
					6'h27:
					begin
						$display("We decode instruction : nor");
						instruction_state <= INST_NOR;
					end

					/* slt $d,$s,$t */
					6'h2A:
					begin
						$display("We decode instruction : slt");
						instruction_state <= INST_SLT;
					end

					endcase
					state <= FETCH_REGISTERS;
					instruction_type <= INST_TYPE_R;
				end
				else
				begin
					case (data_in[31:26])
					/*
					*  Most instructions here are type I except two type J.
					*  since type J does not need to fetch any register, 
					*  let's flag every instruction as type I and process
					*  type J instructions directly without going through the
					*  FETCH_REGISTERS state of the FSM.
					*/

					/* ld $t,C($s) */
					6'h6:
					begin
						$display("We decode instruction : ld");
						instruction_state <= INST_LD;
						memory_load <= 1;
						access_width <= 4'd8;
						signed_load <= 0;
					end

					/* addi $t,$s,C */
					6'h8:
					begin
						$display("We decode instruction : addi");
						instruction_state <= INST_ADDI;
						signed_load <= 0;
					end

					/* lw $t,C($s) */
					6'h23:
					begin
						$display("We decode instruction : lw");
						memory_load <= 1;
						access_width <= 4'd4;
						signed_load <= 0;
					end

					/* lh $t,C($s) */
					6'h21:
					begin
						$display("We decode instruction : lh");
						memory_load <= 1;
						access_width <= 4'd2;
						signed_load <= 1;
					end

					/* lhu $t,C($s) */
					6'h21:
					begin
						$display("We decode instruction : lhu");
						memory_load <= 1;
						access_width <= 4'd2;
						signed_load <= 0;
					end

					/* lb $t,C($s) */
					// FIXME : This should be a SIGNED load
					6'h20:
					begin
						$display("We decode instruction : lb");
						memory_load <= 1;
						access_width <= 4'd1;
						signed_load <= 1;
					end

					/* lbu $t,C($s) */
					6'h24:
					begin
						$display("We decode instruction : lbu");
						memory_load <= 1;
						access_width <= 4'd1;
						signed_load <= 0;
					end

					/* sw $t,C($s) */
					6'h2B:
					begin
						$display("We decode instruction : sw");
						memory_load <= 0;
						access_width <= 4'd4;
					end

					/* sh $t,C($s) */
					6'h29:
					begin
						$display("We decode instruction : sh");
						memory_load <= 0;
						access_width <= 4'd2;
					end

					/* sb $t,C($s) */
					6'h28:
					begin
						$display("We decode instruction : sb");
						memory_load <= 0;
						access_width <= 4'd1;
					end
					endcase
					state <= FETCH_REGISTERS;
					instruction_type <= INST_TYPE_I;
				end
			end
			mem_we_reg <= 0;
			mem_en_reg <= 0;
		end

		FETCH_REGISTERS:
		begin
			case (instruction[25:21])

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

			case (instruction[20:16])
			
			/* $zero (aka $0) is constant 0 */				
			5'd0:	T <= 32'd0;
			/* $at (aka $1) is assembler temporary */
			5'd1:	T <= REG_AT;
			/* $v0 and $v1 (aka $2 an $3) are values for function returns and expression evaluation */
			5'd2:	T <= REG_V0;
			5'd3:	T <= REG_V1;
			/* $a0 to $a3 (aka $4 to $7) are function argument registers */
			5'd4:	T <= REG_A0;
			5'd5:	T <= REG_A1;
			5'd6:	T <= REG_A2;
			5'd7:	T <= REG_A3;
			/* $t0 to $t7 (aka $8 to $15) are temporary registers */
			5'd8:	T <= REG_T0;
			5'd9:	T <= REG_T1;
			5'd10:	T <= REG_T2;
			5'd11:	T <= REG_T3;
			5'd12:	T <= REG_T4;
			5'd13:	T <= REG_T5;
			5'd14:	T <= REG_T6;
			5'd15:	T <= REG_T7;
			/* $s0 to $7 (aka $16 to $23) are saved temporary registers */
			5'd16:	T <= REG_S0;
			5'd17:	T <= REG_S1;
			5'd18:	T <= REG_S2;
			5'd19:	T <= REG_S3;
			5'd20:	T <= REG_S4;
			5'd21:	T <= REG_S5;
			5'd22:	T <= REG_S6;
			5'd23:	T <= REG_S7;
			/* $t8 and $t9 (aka $24 and $25) are temporary registers */
			5'd24:	T <= REG_T8;
			5'd25:	T <= REG_T9;
			/* $k0 and $k1 (aka $26 and $27) are reserved for OS kernel */
			5'd26:	T <= REG_K0;
			5'd27:	T <= REG_K1;
			/* $gp (aka $28) is global pointer register */
			5'd28:	T <= REG_GP;
			/* $sp (aka $29) is stack pointer register */
			5'd29:	T <= REG_SP;
			/* $fp (aka $30) is frame pointer register */
			5'd30:	T <= REG_FP;
			/* $ra (aka $31) is return address register */
			5'd31:	T <= REG_RA;

			endcase

			case (instruction_type)
			INST_TYPE_R:
			begin
				state <= instruction_state;
			end

			INST_TYPE_I:
			begin
				if (memory_load)
					state <= FETCH_FROM_MEM;
				else
				begin
					state <= STORE_TO_MEM;
				end
				C <= instruction[15:0];
			end

			INST_TYPE_J:
			begin
				state <= instruction_state;
			end

			endcase
		end

		FETCH_FROM_MEM:
		begin
			/* memory accesses are 4-bytes aligned */
			mem_addr_reg <= { 2'd0, (S + C) >> 2 };
			address <= S + C;
			mem_we_reg <= 0;
			mem_di_reg <= 32'd0;
			mem_en_reg <= 1;
			mem_bank_select_reg <= 4'b1111;
			$display("Fetching data from memory @ 0x%04X", (S + C));
			state <= FETCH_FROM_MEM_WAIT_ACK;

		end

		STORE_TO_MEM:
		begin
			/* memory accesses are 4-bytes aligned */
			mem_addr_reg <= { 2'd0, (S + C) >> 2 };
			mem_we_reg <= 1;
			mem_di_reg <= T;
			mem_en_reg <= 1;
			$display("Storing data 0x%08X to memory @ 0x%04X", T, (S + C));
			address <= S + C;
			state <= STORE_TO_MEM_WAIT_ACK;
			case ( S[1:0] )
			2'd0:
			begin
				case ( access_width )
					4'd1:	mem_bank_select_reg <= 4'b1000;
					4'd2:	mem_bank_select_reg <= 4'b1100;
					4'd4:	mem_bank_select_reg <= 4'b1111;
					default: mem_bank_select_reg <= 4'd0;
				endcase
			end
			2'd1:
			begin
				case ( access_width )
					4'd1:	mem_bank_select_reg <= 4'b0100;
					default: mem_bank_select_reg <= 4'd0;
				endcase
			end
			2'd2:
			begin
				case ( access_width )
					4'd1:	mem_bank_select_reg <= 4'b0010;
					4'd2:	mem_bank_select_reg <= 4'b0011;
					default: mem_bank_select_reg <= 4'd0;
				endcase
			end
			2'd3:
			begin
				case ( access_width )
					4'd1:	mem_bank_select_reg <= 4'b0001;
					default: mem_bank_select_reg <= 4'd0;
				endcase
			end
			endcase

		end

		FETCH_FROM_MEM_WAIT_ACK:
		begin
			/* Here I save the result in D but it means T
			*  I just wanted to avoid duplicating the 
			*  WRITE_BACK code for T register */
		
			if (mem_do_ack)
			begin
				case (address[1:0])
				2'd0:
				begin
					case (access_width)
					4'd1:	D <= { signed_load ? {24{mem_do[31]}} : 24'd0, mem_do[31:24] };
					4'd2:	D <= { signed_load ? {16{mem_do[31]}} : 16'd0, mem_do[31:16] };
					4'd4:	D <= mem_do;
					endcase
				end
				2'd1:	D <= { signed_load ? {24{ mem_do[25]}} : 24'd0, mem_do[25:16] };
				2'd2:
				begin
					case (access_width)
					4'd1:	D <= { signed_load ? {24{mem_do[15]}} : 24'd0, mem_do[15:8] };
					4'd2:	D <= { signed_load ? {16{mem_do[15]}} : 16'd0, mem_do[15:0] };
					endcase
				end
				2'd3:	D <= { signed_load ? {24{mem_do[7]}} : 24'd0, mem_do[7:0] };
				endcase
				$display("Fetched 0x%08X from memory @ 0x%04X", mem_do, address);
				mem_en_reg <= 0;
				mem_we_reg <= 0;
				mem_addr_reg <= 10'd0;
				state <= WRITE_BACK;
			end
			else
			begin
				state <= FETCH_FROM_MEM_WAIT_ACK;
			end
		end

		STORE_TO_MEM_WAIT_ACK:
		begin
			if (mem_do_ack)
			begin
				$display("Stored 0x%08X to memory @ 0x%04X", mem_do, address);
				mem_en_reg <= 0;
				mem_we_reg <= 0;
				mem_addr_reg <= 10'd0;
				state <= WRITE_BACK;
			end
			else
			begin
				state <= STORE_TO_MEM_WAIT_ACK;
			end
		end

		INST_ADD:
		begin
			$display("We execute add %d, %d", S, T);
			/* We need to execute a trap on overflow */
			// FIXME : TRAP ON OVERFLOW NOT IMPLEMENTED YET
			D <= S + T;
			state <= WRITE_BACK;
		end

		INST_ADDU:
		begin
			$display("We execute addu %d, %d", S, T);
			D <= S + T;
			state <= WRITE_BACK;
		end

		INST_SUB:
		begin
			$display("We execute sub %d, %d", S, T);
			/* We need to execute a trap on overflow */
			// FIXME : TRAP ON OVERFLOW NOT IMPLEMENTED YET
			D <= S - T;
			state <= WRITE_BACK;
		end

		INST_SUBU:
		begin
			$display("We execute subu %d, %d", S, T);
			D <= S + (~T) + 1;
			state <= WRITE_BACK;
		end

		INST_AND:
		begin
			$display("We execute and %d, %d", S, T);
			D <= S & T;
			state <= WRITE_BACK;
		end

		INST_OR:
		begin
			$display("We execute or %d, %d", S, T);
			D <= S | T;
			state <= WRITE_BACK;
		end

		INST_XOR:
		begin
			$display("We execute xor %d, %d", S, T);
			D <= S ^ T;
			state <= WRITE_BACK;
		end

		INST_NOR:
		begin
			$display("We execute nor %d, %d", S, T);
			D <= ~ (S | T);
			state <= WRITE_BACK;
		end

		INST_SLT:
		begin
			$display("We execute slt %d, %d", S, T);

			if (S < T)
				D <= 1;
			else
				D <= 0;

			state <= WRITE_BACK;
		end

		INST_SLL:
		begin
			$display("We execute sll $d, %d, %d", T, instruction[10:6]);
			D <= T << instruction[10:6];
			state <= WRITE_BACK;
		end

		// FIXME : check SRL for compatibility with MIPS32
		INST_SRL:
		begin
			$display("We execute srl $d, %d, %d", T, instruction[10:6]);
			D <= T >> instruction[10:6];
			state <= WRITE_BACK;
		end

		INST_SRA:
		begin
			$display("We execute sra $d, %d, %d", T, instruction[10:6]);
			D <= ~(~T >> instruction[10:6]);
			state <= WRITE_BACK;
		end

		WRITE_BACK:
		begin
			$display("We write back %d to %s", D, (instruction_type == INST_TYPE_R) ? "D" : "T");
			case( (instruction_type == INST_TYPE_R) ? instruction[15:11] : instruction[20:16])
			/* $zero (aka $0) is constant 0 */				
			5'd0:	$display("wtf ?");
			/* $at (aka $1) is assembler temporary */
			5'd1:	REG_AT <= D;
			/* $v0 and $v1 (aka $2 an $3) are values for function returns and expression evaluation */
			5'd2:	REG_V0 <= D;
			5'd3:	REG_V1 <= D;
			/* $a0 to $a3 (aka $4 to $7) are function argument registers */
			5'd4:	REG_A0 <= D;
			5'd5:	REG_A1 <= D;
			5'd6:	REG_A2 <= D;
			5'd7:	REG_A3 <= D;
			/* $t0 to $t7 (aka $8 to $15) are temporary registers */
			5'd8:	REG_T0 <= D;
			5'd9:	REG_T1 <= D;
			5'd10:	REG_T2 <= D;
			5'd11:	REG_T3 <= D;
			5'd12:	REG_T4 <= D;
			5'd13:	REG_T5 <= D;
			5'd14:	REG_T6 <= D;
			5'd15:	REG_T7 <= D;
			/* $s0 to $7 (aka $16 to $23) are saved temporary registers */
			5'd16:	REG_S0 <= D;
			5'd17:	REG_S1 <= D;
			5'd18:	REG_S2 <= D;
			5'd19:	REG_S3 <= D;
			5'd20:	REG_S4 <= D;
			5'd21:	REG_S5 <= D;
			5'd22:	REG_S6 <= D;
			5'd23:	REG_S7 <= D;
			/* $t8 and $t9 (aka $24 and $25) are temporary registers */
			5'd24:	REG_T8 <= D;
			5'd25:	REG_T9 <= D;
			/* $k0 and $k1 (aka $26 and $27) are reserved for OS kernel */
			5'd26:	REG_K0 <= D;
			5'd27:	REG_K1 <= D;
			/* $gp (aka $28) is global pointer register */
			5'd28:	REG_GP <= D;
			/* $sp (aka $29) is stack pointer register */
			5'd29:	REG_SP <= D;
			/* $fp (aka $30) is frame pointer register */
			5'd30:	REG_FP <= D;
			/* $ra (aka $31) is return address register */
			5'd31:	REG_RA <= D;

			endcase
			data_out_reg <= D;
			DOR_reg <= 1;
			state <= WAITING_ACK;
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
			ack_prev_reg <= 0;
		end

		endcase
	end
end

endmodule
