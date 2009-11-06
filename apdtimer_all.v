module apdtimer_all(
	clk,
	operate,
	reset_counter,
	detectors,

	data_rdy,
	data
);

input	clk;
input	operate;
input	reset_counter;
input	[3:0] detectors;

output	data_rdy;
output	[40:0] data;

wire	[3:0] ch;


allclickreg	timer(
	.clk(clk),
	.clear(reset_counter),
	.operate(operate),
	.channel(ch),
	.ready(data_rdy),
	.data(data)
);


clicklatch	latch0(
	.click(operate & detectors[0]),
	.clock(clk),
	.out(ch[0])
);
clicklatch	latch1(
	.click(operate & detectors[1]),
	.clock(clk),
	.out(ch[1])
);
clicklatch	latch2(
	.click(operate & detectors[2]),
	.clock(clk),
	.out(ch[2])
);
clicklatch	latch3(
	.click(operate & detectors[3]),
	.clock(clk),
	.out(ch[3])
);

endmodule
