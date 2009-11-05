// Fast Multisource Pulse Registration System
// Module:
// allclickreg
// Pulse Registration and Time Stamping
// (c) Sergey V. Polyakov 2006-forever
module allclickreg (channel, clk, clear, operate, data, ready);

input [3:0] channel;
input clk;
input clear;
input operate;

output ready; 
output [43:0] data;

reg [38:0] timer;

reg ready;
reg [43:0] data;

initial ready = 1'b0;
initial timer = 39'd0;

always @ (posedge clk)
begin
	if (channel != 3'b0  || (timer == 1'b0 && operate))
	begin
		//data[38:0] <= timer[38:0];
		data[38:0] <= 39'h7F_DEAD_BEEF;		// for debugging
		data[39] <= (timer==1'b0) ? 1'b1 : 1'b0;
		data[43:40] <= channel;
		ready <= 1'b1;
	end
	else
	begin
		ready <= 1'b0;
		data <= 43'b0;
	end	
	timer <= clear ? 39'b0 : timer + 1'b1;
end

endmodule
