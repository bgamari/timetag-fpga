// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module strobe_bits_controller(
	clk,
	mask_bit,
	data, data_ack,
	out
);

input clk;
input mask_bit;
input [7:0] data;
output data_ack;
output [7:0] out;

reg [1:0] state;
reg [7:0] out;

always @(posedge clk)
case (state)
	2'b00:	if (mask_bit)			// It's us, sample data
		begin
			out <= data;
			state <= 2'b01;
		end
		
	2'b01:					// Acknowledge byte, enable output
		state <= 2'b10;

	2'b10:
	begin
		state <= 2'b00;
		out <= 8'b0;
	end
endcase

assign data_ack = state[0];

endmodule
