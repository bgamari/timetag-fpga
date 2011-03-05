module fx2_timetag(
	fx2_clk,
	fx2_flags,
	fx2_slwr,
	fx2_slrd,
	fx2_sloe,
	fx2_wu2,
	fx2_pktend,
	fx2_fd,
	fx2_fifoadr,

	ext_clk,
	delta_in,
	strobe_in,
	led
);

input	fx2_clk;
input	[2:0] fx2_flags;
output	fx2_slwr;
output	fx2_slrd;
output	fx2_sloe;
output	fx2_wu2;
output	fx2_pktend;
inout	[7:0] fx2_fd;
output	[1:0] fx2_fifoadr;

input	ext_clk;
input	[3:0] strobe_in;
input	[3:0] delta_in;
output	[1:0] led;

wire	clk;
wire	cmd_rdy;
wire	[7:0] cmd;

wire	sample_rdy;
wire	[7:0] sample;
wire	sample_ack;

wire	reply_rdy;
wire	[7:0] reply;
wire	reply_ack;
wire	reply_end;


`define USE_EXT_CLK
`ifdef USE_EXT_CLK
altpll0 b2v_inst2(
	.inclk0(ext_clk),
	.c0(clk)
);
`else
assign clk = fx2_clk;
`endif

timetag tagger(
	.fx2_clk(fx2_clk),
	.data_rdy(sample_rdy),
	.data(sample),
	.data_ack(sample_ack),

	.cmd_wr(cmd_rdy),
	.cmd_in(cmd),

	.reply_rdy(reply_rdy),
	.reply(reply),
	.reply_ack(reply_ack),
	.reply_end(reply_end),

	.clk(clk),
	.strobe_in(strobe_in),
	.delta_in(delta_in)
);


fx2_bidir fx2_if(
	.fx2_clk(fx2_clk),
	.fx2_fd(fx2_fd),
	.fx2_flags(fx2_flags),
	.fx2_slrd(fx2_slrd),
	.fx2_slwr(fx2_slwr),
	.fx2_sloe(fx2_sloe),
	.fx2_wu2(fx2_wu2),
	.fx2_pktend(fx2_pktend),
	.fx2_fifoadr(fx2_fifoadr),
	
	.sample(sample),
	.sample_rdy(sample_rdy),
	.sample_ack(sample_ack),
	
	.cmd(cmd),
	.cmd_wr(cmd_rdy),
	
	.reply_rdy(reply_rdy),
	.reply(reply),
	.reply_ack(reply_ack),
	.reply_end(reply_end)
);

led_blinker cmd_rdy_led(
        .clk(fx2_clk),
	.in(cmd_wr),
	.out(led[0])
);

led_blinker sample_rdy_led(
	.clk(fx2_clk),
	.in(sample_rdy),
	.out(led[1])
);

endmodule

