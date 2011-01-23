// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module register(
	clk,
	addr, data,
	value
);
parameter ADDR = 1;

input clk;
input [7:0] addr;
input [7:0] data;
output [7:0] value;

reg [7:0] value;

always @(posedge clk)
	if (addr == ADDR)
		value <= data;

endmodule

