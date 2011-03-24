// Fast Multisource Pulse Registration System
// Ben Gamari (2011)

module register(
	reg_clk, reg_addr, reg_data, reg_wr,

	clk, value
);
parameter ADDR = 1;

input	reg_clk;
input	[15:0] reg_addr;
inout	[31:0] reg_data;
input	reg_wr;

input	clk;
output	[31:0] value;
reg	[31:0] value;

initial value = 32'h0;

always @(posedge reg_clk)
if (reg_addr == ADDR && reg_wr)
	value <= reg_data;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 32'hZZ;
endmodule


module readonly_register(
	reg_clk, reg_addr, reg_data, reg_wr,

	value
);
parameter ADDR = 1;

input	reg_clk;
input	[15:0] reg_addr;
inout	[31:0] reg_data;
input	reg_wr;
input	[31:0] value;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 32'hZZ;
endmodule


module counter_register(
	reg_clk, reg_addr, reg_data, reg_wr,

	increment_clk, increment
);
parameter ADDR = 1;

input	reg_clk;
input	[15:0] reg_addr;
inout	[31:0] reg_data;
input	reg_wr;
input	increment_clk;
input	increment;
reg	[31:0] my_value;
initial my_value = 32'h0;
reg	[31:0] value;
reg	reset;
initial reset = 0;

always @(posedge increment_clk)
begin
	my_value <= reset ? 0 : my_value + 1;
end

always @(posedge reg_clk)
begin
	value <= my_value;
	if (reg_addr == ADDR && reg_wr)
		reset <= 1;
	else if (reset)
		reset <= 0;
end

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 32'hZZ;
endmodule
