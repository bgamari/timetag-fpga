// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Ben Gamari (2010)

module reg_manager(
	clk,
	cmd_wr, cmd_in,
	reply_out, reply_rdy, reply_ack, reply_end,
	
	reg_addr, reg_data, reg_wr
);

// fx2bidir interface
input	clk;
input	cmd_wr;
input	[7:0] cmd_in;
output	[7:0] reply_out;
output	reply_rdy;
input	reply_ack;
output	reply_end;

// Internal interface
output	[15:0] reg_addr;
inout	[31:0] reg_data;
output	reg_wr;

reg	[15:0] addr;
reg	[31:0] data;
reg	[4:0] state;
reg	wants_wr;
initial state = 0;

always @(posedge clk)
case (state)
	0:	if (cmd_in == 8'hAA)		// Read magic number
			state <= 1;

	1:	if (cmd_wr)			// Read message type
		begin
			wants_wr <= cmd_in[0];
			state <= 2;
		end

	2:	if (cmd_wr)			// Read address, 1st byte
		begin
			addr[7:0] <= cmd_in;
			state <= 3;
		end
	3:	if (cmd_wr)			// Read address, 2nd byte
		begin
			addr[15:8] <= cmd_in;
			state <= 4;
		end

	5:	if (cmd_wr)			// Read data, 1st byte
		begin
			data[7:0] <= cmd_in;
			state <= 6;
		end
	6:	if (cmd_wr)			// Read data, 2st byte
		begin
			data[15:8] <= cmd_in;
			state <= 7;
		end
	7:	if (cmd_wr)			// Read data, 3rd byte
		begin
			data[23:16] <= cmd_in;
			state <= 8;
		end
	8:	if (cmd_wr)			// Read data, 4th byte
		begin
			data[31:24] <= cmd_in;
			state <= 9;
		end
		
	7:	state <= 8;			// Write new value to register (if needed)

	8:	if (reply_ack)			// Reply with register value, 1st byte
			state <= 9;
	9:	if (reply_ack)			// Reply with register value, 1st byte
			state <= 10;
	10:	if (reply_ack)			// Reply with register value, 1st byte
			state <= 11;
	11:	if (reply_ack)			// Reply with register value, 1st byte
			state <= 12;

	12:	state <= 0;			// End reply packet
	
	default:
		state <= 0;
endcase

assign reg_addr = (state==7 || state==8 || state==9 || state==10) ? addr : 8'hXX;
assign reg_data = (state==7) ? data : 8'hZZ;
assign reg_wr = (state==7) && wants_wr;

assign reply_out = (state==8)  ? reg_data[7:0] : 
		   (state==9)  ? reg_data[15:8] :
		   (state==10) ? reg_data[23:16] :
		   (state==11) ? reg_data[31:24] : 32'hZZZZZZZZ;
assign reply_rdy = state==8 || state==9 || state==10 || state==11;
assign reply_end = state==12;

endmodule

