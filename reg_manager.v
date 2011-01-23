// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Ben Gamari (2010)

module reg_manager(
	fx2_clk, clk,
	cmd_in, cmd_wr,
	
	addr_out, data_out
);

input fx2_clk;
input clk;
input 	[7:0] cmd_in;
input	cmd_wr;

output 	[7:0] addr_out;
output 	[7:0] data_out;

reg	[1:0] state;
reg	[7:0] data;
reg	[7:0] addr;

initial state = 0;
always @(posedge clk)
case (state)
	0:					// Get address
		if (cmd_wr)
		begin
			addr <= cmd_in;
			state <= 1;
		end
		
	1:					// Get data
		if (cmd_wr)
		begin
			data <= cmd_in;
			state <= 2;
		end
		
	2:					// Send to rest of device
		state <= 0;

	default:
		state <= 0;
endcase

assign addr_out = (state == 2) ? addr : 8'hXX;
assign data_out = (state == 2) ? data : 8'hXX;

endmodule

