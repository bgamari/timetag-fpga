module apdtimer_all(
	clk,
	strobe_in, delta_in,
	reg_clk, reg_addr, reg_data, reg_wr,
	record_rdy, record
);

input	clk;
input	[3:0] strobe_in;
input	[3:0] delta_in;

input	reg_clk;
input	[15:0] reg_addr;
inout	[31:0] reg_data;
input	reg_wr;

output	record_rdy;
output	[46:0] record;

wire	[3:0] strobe_chans;

wire	[31:0] timer_reg;
register #(.ADDR(8'h03)) apdtimer_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(timer_reg)
);
wire	capture_operate = timer_reg[0];
wire	counter_operate = timer_reg[1];
wire	reset_counter = timer_reg[2];

wire [31:0] strobe_operate;
register #(.ADDR(8'h04)) strobe_operate_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(strobe_operate)
);

wire [31:0] delta_operate;
register #(.ADDR(8'h05)) delta_operate_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(delta_operate)
);

event_tagger	tagger(
	.clk(clk),
	.reset_counter(reset_counter),
	.capture_operate(capture_operate),
	.counter_operate(counter_operate),
	.strobe_channels(strobe_chans & strobe_operate[3:0]),
	.delta_channels(delta_in & delta_operate[3:0]),
	.ready(record_rdy),
	.data(record)
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
