module ram(input clock, input [3:0] bank_select, input enable, input [15:0] addr, input [31:0] di, output [31:0] do, input we);

reg [7:0] mem0 [1023:0];
reg [7:0] mem1 [1023:0];
reg [7:0] mem2 [1023:0];
reg [7:0] mem3 [1023:0];
reg [31:0] do;

/* bank 0 */
always @(posedge clock)
begin
	if (enable & bank_select[0])
	begin
		if (we)
		begin
			mem0[addr] <= di[7:0];
		end
		do[7:0] <= mem0[addr];
	end
end

always @(posedge clock)
begin
	if (enable & bank_select[1])
	begin
		if (we)
		begin
			mem1[addr] <= di[15:8];
		end
		do[15:8] <= mem1[addr];
	end
end

always @(posedge clock)
begin
	if (enable & bank_select[2])
	begin
		if (we)
		begin
			mem2[addr] <= di[23:16];
		end
		do[23:16] <= mem2[addr];
	end
end

always @(posedge clock)
begin
	if (enable & bank_select[3])
	begin
		if (we)
		begin
			mem3[addr] <= di[31:24];
		end
		do[31:24] <= mem3[addr];
	end
end

initial
begin
	$readmemh("ram0.data", mem0);
	$readmemh("ram1.data", mem1);
	$readmemh("ram2.data", mem2);
	$readmemh("ram3.data", mem3);
end

endmodule
