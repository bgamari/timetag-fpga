module sample_multiplexer(
	clk,
	sample, sample_rdy, sample_ack,
	data, data_rdy, data_ack
);

input clk;
input [47:0] sample;
input sample_rdy;
output sample_ack;

input data_ack;
output [7:0] data;
output data_rdy;

reg [7:0] data;

reg [1:0] state;
reg [2:0] byte_idx;

initial state = 3'b0;

always @(posedge clk)
case (state)
	2'b00:				// Wait for sample to become available
		if (sample_rdy)
			state <= 2'b01;

	2'b01:				// Send bytes
		if (data_ack)
		begin
			if (byte_idx == 3'd5)
				state <= 2'b10;
			else
				byte_idx <= byte_idx + 3'd1;
		end

	2'b10:				// Acknowledge sample
		state <= 2'b00;
endcase

always
case (byte_idx)
	3'd0: data = sample[47:40];
	3'd1: data = sample[39:32];
	3'd2: data = sample[31:24];
	3'd3: data = sample[23:16];
	3'd4: data = sample[15:8];
	3'd5: data = sample[7:0];
	default: data = 8'b0;
endcase

assign sample_ack = (state == 2'b10);
assign data_rdy = (state == 2'b01);

endmodule

