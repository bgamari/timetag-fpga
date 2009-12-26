// Fast Multisource Pulse Registration System
// Module:
// leddriver
// Holds a LED high for a certain number of cycles when an input goes high
// (c) Sergey V. Polyakov 2006-forever

module leddriver (clk, in, out);

input clk;
input in;
output out;

reg out;
reg [31:0] count;

initial
begin
	count <= 31'b0;
	out <= 0;
end

always @ (posedge clk)
begin
	if (out == 1)
		count = count - 1;
	
	if (in == 1)
	begin
		out = 1;
		count = 2500000;
	end
	
	if (count == 0)
		out = 0;
end

endmodule
