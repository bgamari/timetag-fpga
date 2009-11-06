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
output [40:0] data;

reg [35:0] timer;

reg ready;
reg [40:0] data;

initial ready = 1'b0;
initial timer = 36'd0;

always @ (posedge clk)
begin
	if (channel != 4'b0  || (timer == 1'b0 && operate))
	begin
		//data[35:0] <= timer[35:0];
		data[35:0] <= 36'hA_DEAD_BEEF;		// for debugging
		data[36] <= (timer==1'b0) ? 1'b1 : 1'b0;
		data[40:37] <= channel;
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
