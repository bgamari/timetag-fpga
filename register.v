// Fast Multisource Pulse Registration System
// Ben Gamari (2011)

module register(
	clk,
	reg_addr, reg_data, reg_wr,

	value
);
parameter ADDR = 1;

input   clk;
input   [7:0] reg_addr;
inout   [7:0] reg_data;
input   reg_wr;
output  [7:0] value;

reg     [7:0] value;

always @(posedge clk)
if (reg_addr == ADDR && reg_wr)
        value <= reg_data;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 8'hZZ;
endmodule


module readonly_register(
	clk,
	reg_addr, reg_data, reg_wr,

	value
);
parameter ADDR = 1;

input   clk;
input   [7:0] reg_addr;
inout   [7:0] reg_data;
input   reg_wr;
input   [7:0] value;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 8'hZZ;
endmodule

