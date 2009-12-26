module fx2_bidir_test(
	FX2_CLK,
	FX2_flags,
	FX2_FIFOADR,
	FX2_WU2,
	FX2_PKTEND,
	FX2_SLOE,
	FX2_SLWR,
	FX2_SLRD,
	
	Detector1,
	LED,
	FX2_FD,
	LASER0_EN,
	LASER1_EN,
	LASER2_EN,
	LASER3_EN,
	
	state,
	CMD_WR,
	CMD
);


input	FX2_CLK;
input	[2:0] FX2_flags;
output	[1:0] FX2_FIFOADR;
inout	[7:0] FX2_FD;
output	FX2_WU2;
output	FX2_PKTEND;
output	FX2_SLOE;
output	FX2_SLWR;
output	FX2_SLRD;

input 	Detector1;
output	[1:0] LED;
output  LASER0_EN;
output  LASER1_EN;
output  LASER2_EN;
output  LASER3_EN;

output  [3:0] state;
output  [7:0] CMD;
output  CMD_WR;


reg	    [7:0] DATA;
wire	DATA_AVAILABLE;
wire	[15:0] LENGTH;

wire	REQUEST_LENGTH;
wire	[7:0] CMD;
wire	CMD_WR;
wire	WORD_ACCEPTED;

wire    [3:0] state;


FX2_bidir	b2v_inst1(
	.FX2_CLK(FX2_CLK),
	.FX2_FD(FX2_FD),
	.FX2_flags(FX2_flags),
	.FX2_SLRD(FX2_SLRD),
	.FX2_SLWR(FX2_SLWR),
	.FX2_SLOE(FX2_SLOE),
	.FX2_WU2(FX2_WU2),
	.FX2_FIFOADR(FX2_FIFOADR),
	.FX2_PKTEND(FX2_PKTEND),
	
	.LENGTH(LENGTH),	
	.FPGA_WORD_AVAILABLE(DATA_AVAILABLE),
	.FPGA_WORD(DATA),
	.FPGA_WORD_ACCEPTED(WORD_ACCEPTED),
	.CMD_WR(CMD_WR),
	.REQUEST_LENGTH(REQUEST_LENGTH),
	.CMD(CMD),
	
	.state(state)
);

assign LENGTH[15:0] = 15'd1234;
assign DATA_AVAILABLE = 1;

initial DATA = 8'hDE;
always @(posedge WORD_ACCEPTED) DATA = DATA + 1'b1;

/*
assign LASER0_EN = WORD_ACCEPTED;
assign LASER1_EN = CMD_WR;
assign LASER2_EN = FX2_SLWR;
assign LASER3_EN = FX2_flags[1];
*/

leddriver driver(
	.clk(FX2_CLK),
	.in(CMD_WR),
	.out(LED[0])
);
assign LED[1] = WORD_ACCEPTED;

assign LASER0_EN = state[0];
assign LASER1_EN = state[1];
assign LASER2_EN = state[2];
assign LASER3_EN = state[3];

endmodule
