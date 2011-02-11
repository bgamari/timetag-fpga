// Fast Multisource Pulse Registration System
// Module:
// runonce
// FPGA Board Initialization
// (c) Sergey V. Polyakov 2006-forever
module runonce (out);
output out;
reg out;

initial
begin
	out = 1'b1;
	#2 out =1'b0;
end

endmodule