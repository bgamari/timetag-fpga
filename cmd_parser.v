// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module cmd_parser(
	fx2_clk, clk,
	cmd_in, cmd_wr,
	
	cmd_mask,
	data_ack, data
);

input fx2_clk;
input clk;

input 	[7:0] cmd_in;
input	cmd_wr;

output 	[7:0] cmd_mask;
input	[7:0] data_ack;
output 	[7:0] data;

reg	[7:0] mask;
reg 	[7:0] length;
reg	[2:0] state;
reg	[7:0] sent;


wire [7:0] in_data;
wire [7:0] in_avail;
wire in_empty;
wire in_req;
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


always @(posedge clk)
case (state)
	0:							// Wait for command
		if (~in_empty)
			state <= 1;
	
	1:							// Get command length
	begin
		length <= in_data;
		state <= 2;
	end
		
	2:							// Wait until we have entire command
		if (in_avail == length)
		begin
			mask <= in_data;
			state <= 3;
			sent <= 0;
		end
		
	3:							// Send command data
	begin
		if (sent == length)	//   Done receiving command, move along
			state <= 4;
			
		if (in_req)
			sent <= sent + 8'b1;
	end
	
	4:							// Clear buffer?
		state <= 0;
endcase


assign cmd_mask = (state == 3) ? mask : 8'b0;
assign data = (state == 3) ? in_data : 8'b0;

assign in_req =  ((state == 0) && (~in_empty))
		|| ((state == 2) && (in_avail == length))
		|| ((state == 3) && (data_ack != 8'b0));

//assign clr = (state == 4); // TODO: This shouldn't be necessary but unfortunately is

endmodule

