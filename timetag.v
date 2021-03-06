`include "config.v"

module timetag(
	fx2_clk,
	data_rdy, data, data_ack,
	cmd_wr, cmd_in,
	reply_rdy, reply, reply_ack, reply_end,

	clk,
	strobe_in,
	delta_chs
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
output	[3:0] delta_chs;

// Register framework
wire	[15:0] reg_addr;
wire	[31:0] reg_data;
wire	reg_wr;
reg_manager reg_mgr(
	.clk(fx2_clk),
	.cmd_wr(cmd_wr),
	.cmd_in(cmd_in),
	.reply_out(reply),
	.reply_rdy(reply_rdy),
	.reply_ack(reply_ack),
	.reply_end(reply_end),

	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

readonly_register #(.ADDR(16'h01)) version_reg(
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(`HWVERSION)
);

readonly_register #(.ADDR(16'h02)) clockrate_reg(
       .reg_clk(fx2_clk),
       .reg_addr(reg_addr),
       .reg_data(reg_data),
       .reg_wr(reg_wr),
       .value(`CLOCKRATE)
);

// Sequencer
sequencer seq(
	.clk(clk),
	.outputs(delta_chs),
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

wire	[47:0] record;
wire	record_rdy;
apdtimer_all apdtimer(
	.clk(clk),
	.strobe_in(strobe_in),
	.delta_in(delta_chs),
	.record_rdy(record_rdy),
	.record(record[46:0]),
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);


// Record FIFO
wire rec_buf_full;
wire rec_buf_rdnext;
wire rec_buf_empty;
wire [47:0] rec_buf_out;

// Track dropped records
reg rec_lost;
initial rec_lost = 0;
assign record[47] = rec_lost;

counter_register #(.ADDR(16'h07)) rec_lost_counter(
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.increment_clk(clk),
	.increment(record_rdy && rec_buf_full)
);

always @(posedge clk)
begin
	if (record_rdy && rec_buf_full)
		rec_lost <= 1;
	else if (record_rdy && !rec_buf_full)
		rec_lost <= 0;
end

// Record counter
counter_register #(.ADDR(16'h06)) rec_counter(
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.increment_clk(clk),
	.increment(record_rdy && !rec_buf_full)
);

wire [31:0] fifo_reg;
sample_fifo rec_buf(
	.wrclk(clk),
	.wrreq(record_rdy && !rec_buf_full),
	.wrfull(rec_buf_full),
	.data(record),

	.rdclk(fx2_clk),
	.rdreq(rec_buf_rdnext),
	.rdempty(rec_buf_empty),
	.q(rec_buf_out),
	.aclr(fifo_reg[0])
);

sample_multiplexer mux(
	.clk(fx2_clk),
	.sample_rdy(!rec_buf_empty),
	.sample(rec_buf_out),
	.sample_req(rec_buf_rdnext),

	.data_rdy(data_rdy),
	.data(data),
	.data_ack(data_ack)
);

register #(.ADDR(8'h08)) rec_fifo_reg(
	.reg_clk(fx2_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(fifo_reg)
);

endmodule

