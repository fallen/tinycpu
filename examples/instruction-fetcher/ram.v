module ram(input clock, input enable, input [7:0] addr, input [7:0] di, output [7:0] do, input we);

reg [7:0] mem [1023:0];
reg [7:0] do;

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
