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

reg [0:0] state;

initial state = 1'b0;

always @(posedge clk)
case (state)
	1'b0:	if (mask_bit)			// It's us, sample data
			state <= 1'b1;
		
	1'b1:					// Acknowledge byte
		state <= 1'b0;
endcase

assign data_ack = state[0];
assign out = (state == 1'b0 && mask_bit) ? data : 8'b0;

endmodule

