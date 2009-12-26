module fx2_test(
	FX2_CLK,
	FX2_WU2,

	FX2_FIFOADR, FX2_FD,
	
	FX2_flags,
	FX2_PKTEND,
	FX2_SLOE, FX2_SLWR, FX2_SLRD,
	
	LED, Push_button,

	LASER0_EN,
	LASER1_EN,
	LASER2_EN,
	LASER3_EN
);

input	FX2_CLK;
input	[2:0] FX2_flags;
input 	Push_button;

output	FX2_WU2;
output	[1:0] FX2_FIFOADR;
output	FX2_PKTEND;
output	FX2_SLOE;
output	FX2_SLWR;
output	FX2_SLRD;

output	[1:0] LED;
output  LASER0_EN;
output  LASER1_EN;
output  LASER2_EN;
output  LASER3_EN;
inout	[7:0] FX2_FD;

// FX2 inputs
wire FIFO_RD, FIFO_WR, FIFO_PKTEND, FIFO_DATAIN_OE;
wire FX2_SLRD = ~FIFO_RD;
wire FX2_SLWR = ~FIFO_WR;
assign FX2_SLOE = ~FIFO_DATAIN_OE;
assign FX2_PKTEND = ~FIFO_PKTEND;

wire FIFO2_empty = ~FX2_flags[0];	wire FIFO2_data_available = ~FIFO2_empty;
wire FIFO6_full = ~FX2_flags[1];	wire FIFO6_ready_to_accept_data = ~FIFO6_full;
wire FIFO8_full = ~FX2_flags[2];	wire FIFO8_ready_to_accept_data = ~FIFO8_full;

wire [1:0] FIFO_FIFOADR;
assign FX2_FIFOADR = FIFO_FIFOADR;

assign FX2_WU2 = 1'b0;
assign FIFO_FIFOADR = 2'b10;
assign FX2_FD = 8'hAB;
assign FIFO_RD = 0;
assign FIFO_WR = FIFO6_ready_to_accept_data;
assign FIFO_DATAIN_OE = 0;
assign FIFO_PKTEND = 0;


assign LED[0] = FX2_SLWR;
assign LED[1] = FX2_FIFOADR[0];

assign LASER0_EN = FIFO6_ready_to_accept_data;
assign LASER1_EN = FX2_SLOE;
assign LASER2_EN = FX2_SLWR;
assign LASER3_EN = FX2_CLK;

endmodule
