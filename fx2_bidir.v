// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module fx2_bidir(
	fx2_clk, fx2_fd, fx2_slrd, fx2_slwr, fx2_flags, 
	fx2_sloe, fx2_wu2, fx2_fifoadr, fx2_pktend,
	fpga_word, fpga_word_avail, fpga_word_accepted,
	cmd, cmd_wr,
	length, request_length,
	state
);

//************************************************************************
//FPGA interface
//************************************************************************
input [7:0] fpga_word;
input fpga_word_avail;
input [15:0] length;
output fpga_word_accepted;
output [7:0] cmd;
output cmd_wr;
output request_length;

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

output [3:0] state;


// Alias "FX2" ports as "FIFO" ports to give them more meaningful names.
// FX2 USB signals are active low, take care of them now
// Note: You probably don't need to change anything in this section
wire fifo_clk = fx2_clk;
wire fifo2_empty = ~fx2_flags[0];	wire fifo2_data_available = ~fifo2_empty;
wire fifo6_full = ~fx2_flags[1];	wire fifo6_ready_to_accept_data = ~fifo6_full;
wire fifo8_full = ~fx2_flags[2];	wire fifo8_ready_to_accept_data = ~fifo8_full;
assign fx2_wu2 = 1'b1;

// Wires associated with bidirectional protocol
wire fpga_word_accepted;
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


////////////////////////////////////////////////////////////////////////////////
// Here we wait until we receive some data from either PC or FPGA (default is FPGA).
// If PC speaks, send an end_packet to its fifo to let it grab the collected data.
// Whenever FPGA is ready to transmit data, and the FIFO is not busy talking to PC, 
// accept FPGA's data and signal this back to FPGA

reg [3:0] state;

always @(posedge fifo_clk)
case(state)
	4'b1011:							// Listen/Transmit state
		if (fifo2_data_available) state <= 4'b0001;		//   If PC is sending something, handle it first
		else if (fifo6_full) state <=4'b1001;			//   fifo is full, go to idle
		     
	4'b1001: 							// Idle state
		if (fifo2_data_available) state <= 4'b0001; 		//   There is data to be recieved
		else if (fifo6_ready_to_accept_data) state <=4'b1011;	//   If fifo6 gets emptied, send more
	
	// Receive path:
	4'b0001: state <= 4'b0011;					// Wait for turnaround to read from PC, send REQUEST_LENGTH to summator
	4'b0011: if (fifo2_empty) state <= 4'b1100;			// Receive data. After FIFO is empty, send the data counter on FIFO8
	4'b1100: state <= 4'b1101;					//   Wait a cycle for data counter
	4'b1101: state <= 4'b1110;					//   Transmit high byte of data counter
	4'b1110: state <= 4'b1111;					//   Transmit low byte of data counter
	4'b1111: state <= 4'b1000; 					//   Transmit an end-packet for data counter

	4'b1000:
	begin
		#2 state <= 4'b1010;					// Wait for turnaround to transmit an end-packet
	end
			 
	4'b1010: 							// End of transmission
		if (fifo6_ready_to_accept_data) state <= 4'b1011;	//   Transmit an end-packet and return to listen/transmit
		else state <= 4'b1001;			    		//   But if fifo6 is full return to idle

	default: state <= 4'b1011;
endcase

assign fifo_fifoadr = state[3:2];

// Transmit from PC to FPGA
assign fifo_rd = (state==4'b0011);
assign cmd[7:0] = (state==4'b0011) ? fifo_datain[7:0] : 8'b0;
assign cmd_wr = (state==4'b0011);
assign fifo_datain_oe = (state[3:2] == 2'b00);

// Transmit from FPGA to PC
assign fpga_word_accepted = (state==4'b1011) && fpga_word_avail && fifo2_empty && fifo6_ready_to_accept_data;

assign length_byte = (state==4'b1101) ? length[15:8] : length[7:0];
assign fifo_dataout = (state==4'b1011) ? fpga_word : length_byte;

assign fifo_wr = ((state==4'b1011) && fpga_word_avail && fifo2_empty && fifo6_ready_to_accept_data)
	      || (state==4'b1101)
	      || (state==4'b1110);
				
assign fifo_dataout_oe = ((state==4'b1011) && fpga_word_avail && fifo2_empty && fifo6_ready_to_accept_data)
		      || (state==4'b1101)
		      || (state==4'b1110);
						
assign fifo_pktend = (state==4'b1111)
		 || ((state==4'b1010) && (length < 16'b0000001000000000));

//request length of the data collected prior to computers data query
assign request_length = (state==4'b0001);

endmodule
