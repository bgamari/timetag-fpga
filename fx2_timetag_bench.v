`timescale 1ns/1ns

`define LOG_EVENTS
`define LOG_SAMPLES

module fx2_timetag_bench();

reg clk;
wire fx2_clk;
wire [7:0] fd;
wire [2:0] flags;
wire [1:0] fifoadr;
wire sloe, slrd, slwr, pktend;

reg [3:0] delta_in;
reg [3:0] strobe_in;

wire [35:0] counter = uut.tagger.apdtimer.tagger.timer;

// External Clock
initial clk = 0;
always #2 clk = ~clk;

// Simulate strobe inputs
reg [31:0] strobe_count;
initial strobe_count = 0;
initial strobe_in = 0;
always begin
	#100 strobe_in[0] = 1;
	`ifdef LOG_EVENTS
	$display($time, "  Strobe channel 0 (event %d, counter=%d)", strobe_count, counter);
	`endif
	#5   strobe_in[0] = 0;
	strobe_count = strobe_count + 1;
end
always begin
	#80  strobe_in[1] = 1;
	`ifdef LOG_EVENTS
	$display($time, "  Strobe channel 1 (event %d, counter=%d)", strobe_count, counter);
	`endif
	#5   strobe_in[1] = 0;
	strobe_count = strobe_count + 1;
end

// Simulate delta inputs
initial delta_in = 0;
always begin
	#100 delta_in[0] = 1; $display($time, "  Delta channel 0 (counter=%d)", counter);
	#100 delta_in[0] = 0;
end
always begin
	#200 delta_in[1] = 1; $display($time, "  Delta channel 1 (counter=%d)", counter);
	#300 delta_in[1] = 0;
end

assign lasers_in = 0;

reg [7:0] cmd;
reg cmd_wr, cmd_commit;
wire cmd_sent;

wire [7:0] reply_data;
wire reply_rdy;
wire [7:0] sample_data;
wire sample_rdy;

fx2_test_fixture fx2(
	.ifclk(fx2_clk),
	.fd(fd),
	.slrd(slrd),
	.slwr(slwr),
	.sloe(sloe),
	.fifoadr(fifoadr),
	.pktend(pktend),
	.flags(flags),
	
	.cmd_data(cmd),
	.cmd_wr(cmd_wr),
	.cmd_commit(cmd_commit),
	.cmd_sent(cmd_sent),

	.reply_data(reply_data),
	.reply_rdy(reply_rdy),
	
	.data(sample_data),
	.data_rdy(sample_rdy)
);

// Instantiate the UUT
fx2_timetag uut(
	.fx2_clk(fx2_clk),
	.fx2_flags(flags),
	.fx2_slwr(slwr),
	.fx2_slrd(slrd),
	.fx2_sloe(sloe),
	.fx2_wu2(),
	.fx2_pktend(pktend),
	.fx2_fd(fd),
	.fx2_fifoadr(fifoadr),

	.ext_clk(clk),
	.delta_in(delta_in),
	.strobe_in(strobe_in),
	.led()
);

reg [31:0] reply_buf;

task reg_cmd;
input write;
input [15:0] addr;
input [31:0] value;
begin
	$display($time, "  Register transaction on %04x with value %08x (wr=%d)", addr, value, write);
	#12 cmd=8'hAA; cmd_wr=1;
	#12 cmd=write;
	#12 cmd=addr[7:0];
	#12 cmd=addr[15:8];
	#12 cmd=value[7:0];
	#12 cmd=value[15:8];
	#12 cmd=value[23:16];
	#12 cmd=value[31:24];
	#12 cmd_wr=0; cmd_commit=1;
	#12 cmd_commit=0;
	@(cmd_sent);

	@(posedge fx2_clk && reply_rdy); // HACK perhaps
	@(posedge fx2_clk && reply_rdy) reply_buf[7:0] = reply_data;
	@(posedge fx2_clk && reply_rdy) reply_buf[15:8] = reply_data;
	@(posedge fx2_clk && reply_rdy) reply_buf[23:16] = reply_data;
	@(posedge fx2_clk && reply_rdy) reply_buf[31:24] = reply_data;
	$display($time, "  Register %04x = %08x", addr, reply_buf);
end
endtask

`ifdef LOG_SAMPLES
reg [47:0] sample_buf;
reg [31:0] sample_count;
initial sample_count = 0;
initial begin
	#100 ; // Wait until things stabilize
	forever begin
		@(posedge fx2_clk && sample_rdy);
		@(posedge fx2_clk && sample_rdy) sample_buf[47:40] = sample_data;
		@(posedge fx2_clk && sample_rdy) sample_buf[39:32] = sample_data;
		@(posedge fx2_clk && sample_rdy) sample_buf[31:24] = sample_data;
		@(posedge fx2_clk && sample_rdy) sample_buf[23:16] = sample_data;
		@(posedge fx2_clk && sample_rdy) sample_buf[15:8] = sample_data;
		@(posedge fx2_clk && sample_rdy) sample_buf[7:0] = sample_data;
		sample_count = sample_count + 1;
		$display($time, "  Sample #%d:    %012x", sample_count, sample_buf);
	end
end
`endif

//always @(posedge fx2_clk && sample_rdy) $display($time, "  sample: %02x", sample_data);
	
// This just prints the results in the ModelSim text window
// You can leave this out if you want
//initial $monitor($time, "  cmd(%b %x)", cmd_wr, cmd);

// These statements conduct the actual circuit test
initial begin
	$display($time, "     Starting...");

	#100 ;
	$display($time, "  Starting with garbage");
	#12  cmd=8'hFF; cmd_wr=1;
	#12  cmd=8'hFF;
	#12  cmd=8'hFF;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	#50 ;
	$display($time, "  Testing version register");
	reg_cmd(0, 4'h1, 0);

	#50 ;
	$display($time, "  Testing clockrate register");
	reg_cmd(0, 4'h2, 0);

	#50 ;
	$display($time, "  Resetting counter");
	reg_cmd(1, 4'h3, 32'h04);

	#50 ;
	$display($time, "  Enabling strobe channels");
	reg_cmd(1, 4'h4, 32'h0f);

	#50 ;
	$display($time, "  Starting capture");
	reg_cmd(1, 4'h3, 32'h03);

	$display($time, "  Waiting for some data");

	#4000 ;

	#50 ;
	$display($time, "  Disabling strobe channels");
	reg_cmd(1, 4'h4, 0);

	#1000;

	#50 ;
	$display($time, "  Enabling delta channels");
	reg_cmd(1, 4'h5, 32'h0f);

	#4000 ;

	#50 ;
	$display($time, "  Disabling delta channels");
	reg_cmd(1, 4'h5, 0);
	
	#50 ;
	$display($time, "  Stopping capture");
	reg_cmd(1, 4'h3, 32'h02);

end

endmodule

