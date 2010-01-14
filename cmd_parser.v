// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

// Disable during debugging
`define CMD_TIMEOUT

module cmd_parser(
	fx2_clk, clk,
	cmd_in, cmd_wr,
	
	cmd_mask,
	data, data_ack
);

input fx2_clk;
input clk;

input 	[7:0] cmd_in;
input	cmd_wr;

output 	[7:0] cmd_mask;
output 	[7:0] data;
input	data_ack;

reg	[7:0] mask;
reg	[7:0] length;
reg	[1:0] state;
reg	[7:0] to_send;
`ifdef CMD_TIMEOUT
reg	[7:0] recv_timeout;
`endif

wire [7:0] in_data;
wire [7:0] in_avail;
wire in_empty;
wire in_req;
wire [7:0] data;
wire data_req;
wire clr;

cmd_fifo fifo(
	.wrclk(fx2_clk),
	.wrreq(cmd_wr),
	.data(cmd_in),
	
	.rdclk(clk),
	.rdreq(in_req),
	.rdempty(in_empty),
	.rdusedw(in_avail),
	.q(in_data),
	.aclr(clr)
);
assign clr = 0;


initial state = 0;
always @(posedge clk)
case (state)
	0:					// Wait for command
		if (~in_empty && in_data == 8'hAA) // Check magic number
			state <= 1;
	
	1:					// Get command length
		if (~in_empty)
		begin
			`ifdef CMD_TIMEOUT
			recv_timeout <= 255;
			`endif
			length <= in_data;
			state <= 2;
		end
		
	2:					// Wait until we have entire command in FIFO
	begin
		`ifdef CMD_TIMEOUT
		recv_timeout <= recv_timeout - 1;
		if (recv_timeout == 0)		//   We had to wait too long, give up on command
			state <= 0;
		`endif

		if (in_avail >= length)
		begin
			mask <= in_data;	//   Grab mask
			state <= 3;
			to_send <= length;
		end
	end
		
	3:					// Send command data
	begin
		if (in_req)
			to_send <= to_send - 1;
		if (to_send == 0)		//   Done receiving command, move along
			state <= 0;
	end

	default:
		state <= 0;
endcase


assign cmd_mask = ((state == 3) && (to_send > 0)) ? mask : 8'b0;
assign data = ((state == 3) && (to_send > 0)) ? in_data : 8'hXX;

assign in_req =  ((state == 0) && ~in_empty)
		|| ((state == 1) && ~in_empty)
		|| ((state == 2) && (in_avail >= length))
		|| ((state == 3) && data_ack);

endmodule

