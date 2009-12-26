// Fast Multisource Pulse Registration System
// Module:
// summator
// Summator with synchronious clear input (readout_clear)
// Last sum is kept at the output until the next synchronious readout_clear is recieved
// (c) Sergey V. Polyakov 2006-forever

module summator (
 increment, readout_clr, clk, sum_out
);

input increment, readout_clr, clk;
output [15:0] sum_out;

reg [15:0] sum;
reg [15:0] sum_out;
reg inc_temp;

reg [1:0] state;

initial
begin
	sum <= 16'b0000000000000000;
	sum_out <=16'b0000000000000000;
	inc_temp <=1'b0;
	state <=2'b00;
end

always @(posedge clk)
begin
	case (state)
	2'b00: 
	begin
		sum <= sum + increment;
		if (readout_clr) state <= 2'b01;
	end
	2'b01:
	begin
		inc_temp <= increment;
		sum_out <=sum;
		state <= 2'b10;
	end
	2'b10:
	begin
		sum <= 16'b0000000000000000 + inc_temp + increment;
		state <= 2'b00;
	end
	default:
	begin
	  	sum <= sum + increment;
		state <= 2'b00;
	end
	endcase
end

endmodule