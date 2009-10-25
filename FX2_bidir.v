// Fast Multisource Pulse Registration System
// Module:
// Flexible, 3-fifo multidirectional FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module FX2_bidir(
	FX2_CLK, FX2_FD, FX2_SLRD, FX2_SLWR, FX2_flags, 
	FX2_SLOE, FX2_WU2, FX2_FIFOADR, FX2_PKTEND,
	FPGA_WORD, FPGA_WORD_AVAILABLE, FPGA_WORD_ACCEPTED,
	CMD, CMD_WR, LENGTH, REQUEST_LENGTH, state
);

//************************************************************************
//FPGA interface
//************************************************************************
input [7:0] FPGA_WORD;
input FPGA_WORD_AVAILABLE;
input [15:0] LENGTH;
output FPGA_WORD_ACCEPTED; 
output [7:0] CMD;
output CMD_WR;
output REQUEST_LENGTH;

//************************************************************************
//FX2 interface
//************************************************************************
input FX2_CLK;
output FX2_WU2; // WU2 (USB wakeup, always high)
inout [7:0] FX2_FD;
output [1:0] FX2_FIFOADR; // FIFO address
input [2:0] FX2_flags; // 0: FIFO2 data available,  1: FIFO6 not full,  2: FIFO8 not full
output FX2_SLRD, FX2_SLWR;
output FX2_SLOE; // FIFO data bus output enable
output FX2_PKTEND; // Packet end

output [3:0] state;


// Alias "FX2" ports as "FIFO" ports to give them more meaningful names.
// FX2 USB signals are active low, take care of them now
// Note: You probably don't need to change anything in this section
wire FIFO_CLK = FX2_CLK;
wire FIFO2_empty = ~FX2_flags[0];	wire FIFO2_data_available = ~FIFO2_empty;
wire FIFO6_full = ~FX2_flags[1];	wire FIFO6_ready_to_accept_data = ~FIFO6_full;
wire FIFO8_full = ~FX2_flags[2];	wire FIFO8_ready_to_accept_data = ~FIFO8_full;
assign FX2_WU2 = 1'b1;

// Wires associated with bidirectional protocol
wire FPGA_WORD_ACCEPTED;
wire [7:0] FIFO_DATAOUT;
wire FIFO_WR;
wire FIFO_DATAOUT_OE;

// Wires associated with packet length monitoring and reporting via FIFO8
wire REQUEST_LENGTH;
wire [7:0] length_byte;

// FX2 inputs
wire FIFO_RD,  FIFO_PKTEND, FIFO_DATAIN_OE;
wire FX2_SLRD = ~FIFO_RD;
wire FX2_SLWR = ~FIFO_WR;
assign FX2_SLOE = ~FIFO_DATAIN_OE;
assign FX2_PKTEND = ~FIFO_PKTEND;

wire [1:0] FIFO_FIFOADR;
assign FX2_FIFOADR = FIFO_FIFOADR;

// FX2 bidirectional data bus
wire [7:0] FIFO_DATAIN = FX2_FD;
assign FX2_FD = FIFO_DATAOUT_OE ? FIFO_DATAOUT : 8'hZZ;


////////////////////////////////////////////////////////////////////////////////
// Here we wait until we receive some data from either PC or FPGA (default is FPGA).
// If PC speaks, send an end_packet to its fifo to let it grab the collected data.
// Whenever FPGA is ready to transmit data, and the FIFO is not busy talking to PC, 
// accept FPGA's data and signal this back to FPGA

reg [3:0] state;

always @(posedge FIFO_CLK)
case(state)
	4'b1011: 											 // Listen/Transmit state
			 if (FIFO2_data_available) state <= 4'b0001; //   If PC is sending something, handle it first
		     else if (FIFO6_full) state <=4'b1001;       //   FIFO is full, go to idle
		     
	4'b1001: 											 			// Idle state
	         if (FIFO2_data_available) state <= 4'b0001; 			//   There is data to be recieved
	         else if (FIFO6_ready_to_accept_data) state <=4'b1011;  //   If FIFO6 gets emptied, send more
	
	// Receive path:
	4'b0001: state <= 4'b0011;                          // Wait for turnaround to read from PC, send REQUEST_LENGTH to summator
	4'b0011: if (FIFO2_empty) state <= 4'b1100;			// Receive data. After FIFO is empty, send the data counter on FIFO8
	4'b1100: state <= 4'b1101;                          //   Wait a cycle for data counter
	4'b1101: state <= 4'b1110;                          //   Transmit high byte of data counter
	4'b1110: state <= 4'b1111;                          //   Transmit low byte of data counter
	4'b1111: state <= 4'b1000; 						    //   Transmit an end-packet for data counter

	4'b1000: begin
				#2 state <= 4'b1010;                    // Wait for turnaround to transmit an end-packet
			 end
			 
	4'b1010: 													// End of transmission
			 if (FIFO6_ready_to_accept_data) state <= 4'b1011;	//   Transmit an end-packet and return to listen/transmit
			 else state <= 4'b1001;					    		//   But if FIFO6 is full return to idle
	default: state <= 4'b1011;
endcase

assign FIFO_FIFOADR = state[3:2];

// Transmit from PC to FPGA
assign FIFO_RD = (state==4'b0011);
assign CMD[7:0] = (state==4'b0011) ? FIFO_DATAIN[7:0] : 8'b0;
assign CMD_WR = (state==4'b0011);
assign FIFO_DATAIN_OE = (state[3:2] == 2'b00);

// Transmit from FPGA to PC
assign FPGA_WORD_ACCEPTED = (state==4'b1011) && FPGA_WORD_AVAILABLE && FIFO2_empty && FIFO6_ready_to_accept_data;

assign length_byte = (state==4'b1101) ? LENGTH[15:8] : LENGTH[7:0];
assign FIFO_DATAOUT = (state==4'b1011) ? FPGA_WORD : length_byte;

assign FIFO_WR = ((state==4'b1011) && FPGA_WORD_AVAILABLE && FIFO2_empty && FIFO6_ready_to_accept_data)
			   || (state==4'b1101)
			   || (state==4'b1110);
				
assign FIFO_DATAOUT_OE = ((state==4'b1011) && FPGA_WORD_AVAILABLE && FIFO2_empty && FIFO6_ready_to_accept_data)
					   || (state==4'b1101)
					   || (state==4'b1110);
						
assign FIFO_PKTEND = (state==4'b1111)
				 || ((state==4'b1010) && (LENGTH < 16'b0000001000000000));

//request length of the data collected prior to computers data query
assign REQUEST_LENGTH = (state==4'b0001);

endmodule
