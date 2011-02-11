module apdtimer_all(
	clk,
	strobe_in, delta_in,
	reg_addr, reg_data, reg_wr,
	operate,
	data_rdy, data
);

input	clk;
input	[3:0] strobe_in;
input	[3:0] delta_in;
input	[7:0] reg_addr;
inout	[7:0] reg_data;
input   reg_wr;

output	operate;
output	data_rdy;
output	[46:0] data;

wire	[3:0] ch;

wire	[7:0] timer_reg;
register #(.ADDR(1)) apdtimer_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(timer_reg)
);

wire	capture_operate = timer_reg[0];
wire	counter_operate = timer_reg[1];
wire	reset_counter = timer_reg[2];

event_tagger	timer(
	.clk(clk),
	.reset_counter(reset_counter),
	.capture_operate(capture_operate),
	.counter_operate(counter_operate),
	.strobe_channels(ch),
	.delta_channels(delta_in),
	.ready(data_rdy),
	.data(data)
);


clicklatch	latch0(
	.click(operate & strobe_in[0]),
	.clock(clk),
	.out(ch[0])
);
clicklatch	latch1(
	.click(operate & strobe_in[1]),
	.clock(clk),
	.out(ch[1])
);
clicklatch	latch2(
	.click(operate & strobe_in[2]),
	.clock(clk),
	.out(ch[2])
);
clicklatch	latch3(
	.click(operate & strobe_in[3]),
	.clock(clk),
	.out(ch[3])
);

endmodule
