/* Register the rising edge of a signal */
module strobe_latch (clk, in, out);

input clk;
input in;
output out;

reg state;
reg out;
initial out = 0;

always @(posedge clk)
begin
	if (in == 1 && state == 0)
	begin
		state <= 1;
		out <= 1;
	end
	else
	begin
		if (out == 1)
			out <= 0;
	end
	
	if (in == 0)
		state <= 0;
end

endmodule
