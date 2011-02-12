`timescale 1ns/1ns

module fx2_timetag_bench();

reg clk;
wire fx2_clk;
wire [7:0] fd;
wire [2:0] flags;
wire [1:0] fifoadr;
wire sloe, slrd, slwr, pktend;

reg [3:0] detectors_in;
wire [3:0] lasers_in;


// External Clock
initial clk = 0;
always #2 clk = ~clk;

// Simulate photons
//`define RANDOM_PHOTONS 1
`ifdef RANDOM_PHOTONS
	initial begin
		if ((4'b1111 & $random) == 4'b0)
		begin
			detectors_in[0] = 1'b1;
			#10 detectors_in[0] = 1'b0;
		end
	end
`else
	initial detectors_in = 4'b0000;
	always begin
		#100 detectors_in[0] = 1'b1;
		#5  detectors_in[0] = 1'b0;
	end
	always begin
		#80  detectors_in[1] = 1'b1;
		#5  detectors_in[1] = 1'b0;
	end
`endif

assign lasers_in = 0;

reg [7:0] cmd;
reg cmd_wr, cmd_commit;
wire cmd_sent;

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
	.cmd_sent(cmd_sent)
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
	.delta_in(lasers_in),
	.strobe_in(detectors_in),
	.led()
);

// This just prints the results in the ModelSim text window
// You can leave this out if you want
initial $monitor($time, "  cmd(%b %x)", cmd_wr, cmd);

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

	#20 ;
	$display($time, "  Testing version register");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h00;
	#12  cmd=8'h01;
	#12  cmd=8'h00;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	#20 ;
	$display($time, "  Testing clockrate register");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h00;
	#12  cmd=8'h02;
	#12  cmd=8'h00;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	#20 ;
	$display($time, "  Resetting counter");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h01;
	#12  cmd=8'h03;
	#12  cmd=8'h04;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	#20 ;
	$display($time, "  Enabling strobe channels");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h01;
	#12  cmd=8'h04;
	#12  cmd=8'h0f;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	#20 ;
	$display($time, "  Starting capture");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h01;
	#12  cmd=8'h03;
	#12  cmd=8'h03;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	$display($time, "  Waiting for some data");

	#10000 ;
	$display($time, "  Stopping capture");
	#12  cmd=8'hAA; cmd_wr=1;
	#12  cmd=8'h01;
	#12  cmd=8'h01;
	#12  cmd=8'h02;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

end

endmodule

