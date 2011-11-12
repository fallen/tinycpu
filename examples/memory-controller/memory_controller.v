module memory_controller(clk, 
			 devices_mem_en, 
			 device_1_mem_addr, 
			 device_2_mem_addr, 
			 device_1_mem_di, 
			 device_2_mem_di, 
			 devices_mem_we, 
			 mem_do);

input 	clk;
input	[1:0] devices_mem_en;
input	[7:0] device_1_mem_addr;
input	[7:0] device_2_mem_addr;
input	[7:0] device_1_mem_di;
input	[7:0] device_2_mem_di;
input	[1:0] devices_mem_we;
output	[7:0] mem_do;

reg	mem_enable = 0;
reg	[7:0] mem_addr = 7'd0;
reg	[7:0] mem_di = 7'd0;
reg	[2:0] current_slave = 3'd0;
reg	mem_we = 0;

parameter DEVICE_1 = 3'd0;
parameter DEVICE_2 = 3'd1;
parameter NO_ONE = 3'b111;

always @(posedge clk)
begin
	if (current_slave == NO_ONE)
		mem_enable <= 0;
	else
		mem_enable <= devices_mem_en[0] | devices_mem_en[1];
end

always @(posedge clk)
begin
	case (current_slave)
		
	DEVICE_1:
	begin
		mem_addr <= device_1_mem_addr;
		mem_di <= device_1_mem_di;
		mem_we <= devices_mem_we[0];
	end

	DEVICE_2:
	begin
		mem_addr <= device_2_mem_addr;
		mem_di <= device_2_mem_di;
		mem_we <= devices_mem_we[1];
	end

	NO_ONE:
	begin
		mem_addr <= 7'd0;
		mem_di <= 7'd0;
		mem_we <= 0;
	end

	endcase
end

always @(posedge clk)
begin
	
end

ram mem(clk, mem_enable, mem_addr, mem_di, mem_do, mem_we);

endmodule
