module apdtimer_all(
	clk,
	strobe_in, delta_in,
	reg_addr, reg_data, reg_wr,
	data_rdy, data
);

input	clk;
input	[3:0] strobe_in;
input	[3:0] delta_in;
input	[7:0] reg_addr;
inout	[7:0] reg_data;
input   reg_wr;

output	data_rdy;
output	[46:0] data;

wire	[3:0] strobe_chans;

wire	[7:0] timer_reg;
register #(.ADDR(8'h03)) apdtimer_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(timer_reg)
);
wire	capture_operate = timer_reg[0];
wire	counter_operate = timer_reg[1];
wire	reset_counter = timer_reg[2];

wire [7:0] strobe_operate;
register #(.ADDR(8'h04)) strobe_operate_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(strobe_operate)
);

wire [7:0] delta_operate;
register #(.ADDR(8'h05)) delta_operate_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(delta_operate)
);

event_tagger	tagger(
	.clk(clk),
	.reset_counter(reset_counter),
	.capture_operate(capture_operate),
	.counter_operate(counter_operate),
	.strobe_channels(strobe_chans & strobe_operate[3:0]),
	.delta_channels(delta_in & delta_operate[3:0]),
	.ready(data_rdy),
	.data(data)
);


strobe_latch	latch0(
	.clk(clk),
	.in(strobe_in[0]),
	.out(strobe_chans[0])
);
strobe_latch	latch1(
	.clk(clk),
	.in(strobe_in[1]),
	.out(strobe_chans[1])
);
strobe_latch	latch2(
	.clk(clk),
	.in(strobe_in[2]),
	.out(strobe_chans[2])
);
strobe_latch	latch3(
	.clk(clk),
	.in(strobe_in[3]),
	.out(strobe_chans[3])
);

endmodule
