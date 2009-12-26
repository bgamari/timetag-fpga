// Fast Multisource Pulse Registration System
// Module:
// clicklatch
// Pulse Edge Detection
// (c) Sergey V. Polyakov 2006-forever
module clicklatch (click, clock, out);

input click;
input clock;

output out;

reg state;
reg out;

initial out = 0;

always @ (posedge clock)
begin
	if (click == 1'b1 && state == 1'b0)
	begin
		state <= 1'b1;
		out <= 1'b1;
	end
	else
	begin
		if (out == 1'b1 )
		begin
			out <= 1'b0;
		end
	end
	
	if (click == 1'b0 )
	begin
		state <= 1'b0;
	end	
		
end

endmodule

