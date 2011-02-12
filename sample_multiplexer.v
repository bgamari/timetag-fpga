module sample_multiplexer(
	clk,
	sample, sample_rdy, sample_req,
	data, data_rdy, data_ack
);

input clk;
input [47:0] sample;
input sample_rdy;
output sample_req;

input data_ack;
output [7:0] data;
output data_rdy;

wire [7:0] data;

reg [1:0] state;
reg [2:0] byte_idx;

initial state = 0;

always @(posedge clk)
case (state)
	0:				// Wait for sample to become available
		if (sample_rdy)
		begin
			state <= 1;
			byte_idx <= 0;
		end

	1:				// Request a record from the fifo
		state <= 2;
		
	2:				// Send bytes
		if (data_ack)
		begin
			if (byte_idx == 3'd5)
				state <= 0;
			else
				byte_idx <= byte_idx + 3'd1;
		end
endcase

assign data[7:0] = 
	(byte_idx == 3'd0) ? sample[47:40] :
	(byte_idx == 3'd1) ? sample[39:32] :
	(byte_idx == 3'd2) ? sample[31:24] :
	(byte_idx == 3'd3) ? sample[23:16] :
	(byte_idx == 3'd4) ? sample[15:8] :
	(byte_idx == 3'd5) ? sample[7:0] :
	8'b0;

assign data_rdy = (state == 2);
assign sample_req = (state == 1);

endmodule

