module top;

reg clk = 0;
reg reset = 1;

always #5 clk = !clk;


initial
begin
	$display("Starting pipeline example");
	$dumpfile("top.vcd");
	$dumpvars(0, top);
	# 10 reset = 0;
	# 200 $stop;
	$finish;
end

endmodule
