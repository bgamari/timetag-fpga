// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Ben Gamari (2010)

module reg_manager(
	fx2_clk,
	cmd_wr, cmd_in,
        reply_out, reply_rdy, reply_ack, reply_end,
	
        clk,
	reg_addr, reg_data, reg_wr
);

// fx2bidir interface
input   fx2_clk;
input	cmd_wr;
input 	[7:0] cmd_in;
output  [7:0] reply_out;
output  reply_rdy;
input   reply_ack;
output  reply_end;

// Internal interface
input   clk;
output	[7:0] reg_addr;
inout  	[7:0] reg_data;
output  reg_wr;

reg	[7:0] addr;
reg	[7:0] data;
reg	[2:0] state;
reg     wants_wr;
initial state = 0;

always @(posedge clk)
case (state)
        0:                                      // Read message type
                if (cmd_wr)
                begin
                        wants_wr <= cmd_in[0];
                        state <= 1;
                end

	1:					// Read address
		if (cmd_wr)
		begin
			addr <= cmd_in;
			state <= 2;
		end
		
	2:					// Read data
		if (cmd_wr)
		begin
			data <= cmd_in;
			state <= 3;
		end
		
	3:					// Do write (if needed)
                state <= 4;

        4:                                      // Send reply
                if (reply_ack)                  // Wait until fx2bidir acks
                        state <= 5;

        5:                                      // End reply packet
                state <= 0;
        
	default:
		state <= 0;
endcase

assign reg_addr = (state == 3 || state == 4) ? reg_addr : 8'hXX;
assign reg_data = (state == 3 || state == 4) ? reg_data : 8'hZZ;
assign reg_wr = (state == 3) && wants_wr;

assign reply_out = (state == 4) ? data : 8'hXX;
assign reply_rdy = state == 4;
assign reply_end = state == 5;

endmodule

