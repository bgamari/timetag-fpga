module apdtimer_all(
	clk,
	operate,
	reset_counter,
	strobe_in, delta_in,
	pulseseq_outputs,

	data_rdy,
	data
);

input	clk;
input	operate;
input	reset_counter;
input	[3:0] strobe_in;
input	[3:0] delta_in;
input   [3:0] pulseseq_outputs;

output	data_rdy;
output	[46:0] data;

wire	[3:0] ch;


event_tagger	timer(
	.clk(clk),
	.reset_counter(reset_counter),
	.operate(operate),
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
