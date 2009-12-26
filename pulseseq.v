// Fast Multisource Pulse Registration System
// Module:
// Pulse sequencer
// (c) Ben Gamari 2009

module pulse_sequencer(
	clk, operate,
	out,

	set_initial_state, set_initial_count, set_hi_count, set_lo_count,
	value
);

input clk;
input operate;

input [31:0] value;
input set_initial_state;
input set_initial_count;
input set_hi_count;
input set_lo_count;

output out;

reg [31:0] hi_count;
reg [31:0] lo_count;

reg [31:0] count;
reg out;

initial out = 0;

always @(posedge clk)
begin
	if (set_initial_state)
		out <= (value == 32'b0);
	if (set_initial_count)
		count <= value;
	if (set_hi_count)
		hi_count <= value;
	if (set_lo_count)
		lo_count <= value;
		
	if (operate)
	begin
		if (count == 0)
		begin
			out <= ~out;
			if (out)	count <= lo_count;
			else		count <= hi_count;
		end
		else
			count <= count - 32'b1;
	end
end

endmodule
