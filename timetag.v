module timetag(
	fx2_clk,
	request_length, length,
	data_avail, data, data_accepted,
	cmd_wr, cmd_in,

	clk,
	detectors,
	laser_en
);

input	fx2_clk;
output	data_avail;
output	[7:0] data;
input	data_accepted;

// For Host->FPGA command submission
input	cmd_wr;
input	[7:0] cmd_in;
input	request_length;
output	[15:0] length;

// For FPGA->Host data submission
input	clk;
input	[3:0] detectors;
output	[3:0] laser_en;

wire	[47:0] sample;
wire    sample_rdy;

// Internal command tracking signals
wire	[7:0] cmd_avail;
wire	[7:0] cmd_data;
wire	[7:0] cmd_ack;
assign cmd_ack[7:6] = 0;

cmd_parser cmd_parser(
	.fx2_clk(fx2_clk),
	.clk(clk),
	.cmd_wr(cmd_wr),
	.cmd_in(cmd_in),

	.cmd_mask(cmd_avail),
	.data(cmd_data),
	.data_ack(cmd_ack != 0)
);

wire	[7:0] timer_cmd;
strobe_bits_controller apdtimer_controller(
	.clk(clk),
	.mask_bit(cmd_avail[0]),
	.data(cmd_data),
	.data_ack(cmd_ack[0]),
	.out(timer_cmd)
);

`define TEST_OUTPUT 1
`ifdef TEST_OUTPUT

reg timer_operate = 0;
always @(posedge clk)
	timer_operate = (timer_operate | timer_cmd[0]) & ~timer_cmd[1];

apdtimer_all apdtimer(
	.clk(clk),
	.detectors(detectors),
	.pulseseq_outputs(laser_en),
	.operate(timer_operate),
	.reset_counter(timer_cmd[2]),

	.data_rdy(sample_rdy),
	.data(sample[46:0])
);


wire	[7:0] seqop_cmd;
strobe_bits_controller pulse_seq_operate_controller(
	.clk(clk),
	.mask_bit(cmd_avail[1]),
	.data(cmd_data),
	.data_ack(cmd_ack[1]),
	.out(seqop_cmd)
);

reg pulse_seq_operate = 0;
always @(posedge clk)
	pulse_seq_operate = (pulse_seq_operate | seqop_cmd[0]) & ~seqop_cmd[1];

cntrl_pulse_sequencer pulseseq0(
	.clk(clk),
	.operate(pulse_seq_operate),
	.mask_bit(cmd_avail[2]),
	.cmd_data(cmd_data),
	.data_ack(cmd_ack[2]),
	.out(laser_en[0])
);
cntrl_pulse_sequencer pulseseq1(
	.clk(clk),
	.operate(pulse_seq_operate),
	.mask_bit(cmd_avail[3]),
	.cmd_data(cmd_data),
	.data_ack(cmd_ack[3]),
	.out(laser_en[1])
);
cntrl_pulse_sequencer pulseseq2(
	.clk(clk),
	.operate(pulse_seq_operate),
	.mask_bit(cmd_avail[4]),
	.cmd_data(cmd_data),
	.data_ack(cmd_ack[4]),
	.out(laser_en[2])
);
cntrl_pulse_sequencer pulseseq3(
	.clk(clk),
	.operate(pulse_seq_operate),
	.mask_bit(cmd_avail[5]),
	.cmd_data(cmd_data),
	.data_ack(cmd_ack[5]),
	.out(laser_en[3])
);

assign sample[47:44] = laser_en[3:0];

`else

reg [31:0] count;
initial count = 0;
always @(posedge clk)
begin
	if (count == 0)
		count <= 32'd480000;
	else
		count <= count - 1;
end

assign sample_rdy = (count == 0);
assign sample = 48'hfeeddeadbeed;
//assign cmd_ack = 1'b1;

`endif

//////////////////////////////
// Sample FIFO


wire samp_buf_full;
wire samp_buf_rdnext;
wire samp_buf_empty;
wire [47:0] samp_buf_out;

reg samp_lost;
initial samp_lost = 0;
assign sample[41] = samp_lost;

// Track dropped samples
always @(posedge clk)
begin
	if (sample_rdy && samp_buf_full)
		samp_lost <= 1;
	else if (sample_rdy && ~samp_buf_full)
		samp_lost <= 0;
end

sample_fifo samp_buf(
	.wrclk(clk),
	.wrreq(sample_rdy & ~samp_buf_full),
	.wrfull(samp_buf_full),
	.data(sample),

	.rdclk(fx2_clk),
	.rdreq(samp_buf_rdnext),
	.rdempty(samp_buf_empty),
	.q(samp_buf_out)
);


sample_multiplexer multiplexer(
	.clk(fx2_clk),
	.sample_rdy(~samp_buf_empty),
	.sample(samp_buf_out),
	.sample_ack(samp_buf_rdnext),

	.data_rdy(data_avail),
	.data(data),
	.data_ack(data_accepted)
);

summator sample_counter(
	.clk(clk),
	.increment(sample_rdy & ~samp_buf_full),
	.readout_clr(request_length),
	.sum_out(length)
);

endmodule

