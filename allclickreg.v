// Fast Multisource Pulse Registration System
// Module:
// allclickreg
// Pulse Registration and Time Stamping
// (c) Sergey V. Polyakov 2006-forever
module allclickreg (strobe_channels, delta_channels, clk, clear, operate, data, ready);

input [3:0] strobe_channels;
input [3:0] delta_channels;

input clk;
input clear;
input operate;

output ready; 
output [46:0] data;

reg [35:0] timer;
reg [3:0] old_delta;

reg ready;
reg [46:0] data;

initial data = 47'b0;
initial ready = 1'b0;
initial timer = 36'd0;
initial old_delta = 4'b0;

always @(posedge clk)
begin
	if (delta_channels != old_delta)			// First monitor delta inputs
	begin
		data[35:0] <= timer[35:0];
		data[39:36] <= delta_channels;
		data[45] <= 1;					// record type
		data[46] <= (timer==1'b0) ? 1'b1 : 1'b0;	// wraparound
		ready <= 1'b1;
		old_delta <= delta_channels;
	end
	else if (strobe_channels != 4'b0 || (timer == 1'b0 && operate))
	begin
		data[35:0] <= timer[35:0];
		//data[35:0] <= 36'hA_DEAD_BEEF;  // for debugging
		data[39:36] <= strobe_channels;
		data[45] <= 0;					// record type
		data[46] <= (timer==1'b0) ? 1'b1 : 1'b0;	// wraparound
		ready <= 1'b1;
	end
	else
	begin
		ready <= 1'b0;
		data <= 40'bZ;
	end	
	timer <= clear ? 36'b0 : timer + 1'b1;
end

endmodule

