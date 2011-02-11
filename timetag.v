`include "config.v"

module timetag(
	fx2_clk,
	data_rdy, data, data_ack,
	cmd_wr, cmd_in,
	reply_rdy, reply, reply_ack, reply_end,

	clk,
	strobe_in,
	delta_in,

	capture_operate
);

// Clocks
input	fx2_clk;
input	clk;

// For Host->FPGA commands
input	cmd_wr;
input	[7:0] cmd_in;

// For FPGA->Host command replies
output	reply_rdy;
output	[7:0] reply;
input	reply_ack;
output	reply_end;

// For FPGA->Host data
output	data_rdy;
output	[7:0] data;
input	data_ack;

// Acquisition inputs
input	[3:0] strobe_in;
input	[3:0] delta_in;

// Status outputs
output	capture_operate;

// Register framework
wire	[7:0] reg_addr;
wire	[7:0] reg_data;
wire	reg_wr;
reg_manager reg_mgr(
	.fx2_clk(fx2_clk),
	.cmd_wr(cmd_wr),
	.cmd_in(cmd_in),
	.reply_out(reply),
	.reply_rdy(reply_rdy),
	.reply_ack(reply_ack),
	.reply_end(reply_end),

	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

readonly_register #(.ADDR(8'h01)) version_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(`HWVERSION)
);

readonly_register #(.ADDR(8'h02)) clock_reg(
	.clk(clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(`CLOCKRATE)
);

//`define TEST_OUTPUT
`ifdef TEST_OUTPUT

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
assign sample[46:0] = 47'hfeeddeadbeef;
//assign cmd_ack = 1'b1;

`else

wire	[47:0] sample;
wire	sample_rdy;
apdtimer_all apdtimer(
	.clk(clk),
	.strobe_in(strobe_in),
	.delta_in(delta_in),
	.data_rdy(sample_rdy),
	.data(sample[46:0]),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.operate()
);

`endif


// Sample FIFO
wire samp_buf_full;
wire samp_buf_rdnext;
wire samp_buf_empty;
wire [47:0] samp_buf_out;

reg samp_lost;
initial samp_lost = 0;
assign sample[47] = samp_lost;

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

	.data_rdy(data_rdy),
	.data(data),
	.data_ack(data_ack)
);

endmodule

