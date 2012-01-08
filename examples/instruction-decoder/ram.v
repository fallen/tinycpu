module ram(input clock, input enable, input [9:0] addr, input [31:0] di, output [31:0] do, input we);

reg [31:0] mem [1023:0];
reg [31:0] do;

always @(posedge clock)
begin
	if (enable)
	begin
		if (we)
		begin
			mem[addr] <= di;
		end
		do <= mem[addr];
	end
end

initial
begin
	$readmemh("ram.data", mem);
end

endmodule
