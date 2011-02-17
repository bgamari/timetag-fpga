// Fast Multisource Pulse Registration System
// Ben Gamari (2011)

module register(
	clk,
	reg_addr, reg_data, reg_wr,

	value
);
parameter ADDR = 1;

input   clk;
input   [15:0] reg_addr;
inout   [31:0] reg_data;
input   reg_wr;
output  [31:0] value;
reg     [31:0] value;

always @(posedge clk)
if (reg_addr == ADDR && reg_wr)
        value <= reg_data;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 32'hZZ;
endmodule


module readonly_register(
	clk,
	reg_addr, reg_data, reg_wr,

	value
);
parameter ADDR = 1;

input   clk;
input   [15:0] reg_addr;
inout   [31:0] reg_data;
input   reg_wr;
input   [31:0] value;

assign reg_data = (reg_addr == ADDR && !reg_wr) ? value : 32'hZZ;
endmodule

