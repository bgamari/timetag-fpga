module apdtimer_all(
	clk,
	start_det, stop_det, reset_counter,
	detectors,

	running,
	data_rdy,
	data
);

input	clk;
input	start_det;
input	stop_det;
input	reset_counter;
input	[3:0] detectors;

output	running;
output	data_rdy;
output	[43:0] data;

wire	[3:0] ch;
reg running;


initial running = 0;

always@(posedge clk)
begin
	if (stop_det)
		running <= 0;
	else if (start_det)
		running <= 1;
end


allclickreg	b2v_inst1(
	.clk(clk),
	.clear(reset_counter),
	.operate(running),
	.channel(ch),
	.ready(data_rdy),
	.data(data));


clicklatch	b2v_inst11(
	.click(running & detectors[0]),
	.clock(clk),
	.out(ch[0]));

clicklatch	b2v_inst4(
	.click(running & detectors[1]),
	.clock(clk),
	.out(ch[1]));

clicklatch	b2v_inst9(
	.click(running & detectors[2]),
	.clock(clk),
	.out(ch[2]));

clicklatch	b2v_inst10(
	.click(running & detectors[3]),
	.clock(clk),
	.out(ch[3]));


endmodule
