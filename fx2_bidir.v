// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module fx2_bidir(
	fx2_clk, fx2_fd, fx2_slrd, fx2_slwr, fx2_flags, 
	fx2_sloe, fx2_wu2, fx2_fifoadr, fx2_pktend,
	sample, sample_rdy, sample_ack,
	cmd, cmd_wr,
	reply, reply_rdy, reply_ack, reply_end
);

//************************************************************************
//FPGA interface
//************************************************************************
input [7:0] sample;
input sample_rdy;
output sample_ack;
output [7:0] cmd;
output cmd_wr;
input [7:0] reply;
input reply_rdy;
output reply_ack;
input reply_end;

//************************************************************************
//FX2 interface
//************************************************************************
input fx2_clk;
output fx2_wu2; // WU2 (USB wakeup, always high)
inout [7:0] fx2_fd;
output [1:0] fx2_fifoadr; // FIFO address
input [2:0] fx2_flags; // 0: FIFO2 data available,  1: FIFO6 not full,  2: FIFO8 not full
output fx2_slrd, fx2_slwr;
output fx2_sloe; // FIFO data bus output enable
output fx2_pktend; // Packet end


// Alias "FX2" ports as "FIFO" ports to give them more meaningful names.
// FX2 USB signals are active low, take care of them now
// Note: You probably don't need to change anything in this section
wire fifo_clk = fx2_clk;
wire fifo2_empty = ~fx2_flags[0];	wire fifo2_data_available = ~fifo2_empty;
wire fifo6_full = ~fx2_flags[1];	wire fifo6_ready_to_accept_data = ~fifo6_full;
wire fifo8_full = ~fx2_flags[2];	wire fifo8_ready_to_accept_data = ~fifo8_full;
assign fx2_wu2 = 1'b1;

// Wires associated with bidirectional protocol
wire sample_ack;
wire [7:0] fifo_dataout;
wire fifo_dataout_oe;
wire fifo_wr;

// Wires associated with packet length monitoring and reporting via FIFO8
wire request_length;
wire [7:0] length_byte;

// FX2 inputs
wire fifo_rd,  fifo_pktend, fifo_datain_oe;
wire fx2_slrd = ~fifo_rd;
wire fx2_slwr = ~fifo_wr;
assign fx2_sloe = ~fifo_datain_oe;
assign fx2_pktend = ~fifo_pktend;

wire [1:0] fifo_fifoadr;
assign fx2_fifoadr = fifo_fifoadr;

// FX2 bidirectional data bus
wire [7:0] fifo_datain = fx2_fd;
assign fx2_fd = fifo_dataout_oe ? fifo_dataout : 8'hZZ;


/*
 * Here we wait until we receive some data from either PC or FPGA (default is FPGA).
 * If PC speaks, send an end_packet to its fifo to let it grab the collected data.
 * Whenever FPGA is ready to transmit data, and the FIFO is not busy talking to PC, 
 * accept FPGA's data and signal this back to FPGA
 */

/*
 * state[3:2]: fidoadr
 */
reg [3:0] state;

always @(posedge fifo_clk)
case(state)
	// Idle
	4'b1001: 							// Idle state
		if (fifo2_data_available) state <= 4'b0001; 		//   There is data to be recieved
		else if (fifo6_ready_to_accept_data) state <= 4'b1011;	//   If fifo6 gets emptied, send more
		else if (reply_rdy && fifo8_ready_to_accept_data) state <= 4'b1110;
	
	// Data transmit path
	4'b1011:							// Listen/Transmit state
		if (fifo2_data_available) state <= 4'b0001;		//   If PC is sending something, handle it first
		else if (fifo6_full) state <=4'b1001;			//   fifo is full, go to idle
		     
	// Command receive path:
	4'b0001: state <= 4'b0011;					// Wait for turnaround to read from PC
	4'b0011: if (fifo2_empty) state <= 4'b1001;			// Receive data

	// Command reply path:
	4'b1110: if (reply_end) state <= 4'b1111;			// Transmit data
	4'b1111: state <= 4'b1000; 					// Transmit end-of-packet
	4'b1000:							// Wait for turnaround to transmit an end-of-packet
	begin
		#2 state <= 4'b1010;
	end
			 
	default: state <= 4'b1011;
endcase

assign fifo_fifoadr = state[3:2];

// Transmit from PC to FPGA
assign fifo_rd = (state==4'b0011);
assign cmd[7:0] = (state==4'b0011) ? fifo_datain[7:0] : 8'b0;
assign cmd_wr = (state==4'b0011);
assign fifo_datain_oe = (state[3:2] == 2'b00);

// Transmit from FPGA to PC
wire can_xmit_sample = (state==4'b1011) && sample_rdy && fifo2_empty && fifo6_ready_to_accept_data;
assign sample_ack = can_xmit_sample;

assign fifo_dataout = (state==4'b1011) ? sample : reply;

assign fifo_wr = can_xmit_sample || (state==4'b1110);

assign fifo_dataout_oe = can_xmit_sample || (state==4'b1110);
						
assign fifo_pktend = (state==4'b1111);

assign reply_ack = (state==4'b1110);

endmodule

