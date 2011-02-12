/* Register the rising edge of a signal */
module strobe_latch (clk, in, out);

input clk;
input in;
output out;

reg out;
initial out = 0;

always @(posedge in)
	out <= 1;

always @(posedge clk)
	if (out)
		out <= 0;

endmodule
