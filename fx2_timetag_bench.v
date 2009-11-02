`timescale 1ns/1ns

module fx2_timetag_bench();

reg clk;
wire fx2_clk;
wire [7:0] fd;
wire [2:0] flags;


wire [1:0] fifoadr;
wire [15:0] length;
reg request_length;


wire [7:0] data;
wire data_avail;
reg data_accepted;

reg [3:0] detectors;
wire [3:0] laser_en;


// External Clock
initial clk = 0;
always #2 clk = ~clk;

// Simulate photons
initial detectors = 4'b0000;
always begin
	#100 detectors[0] = 1'b1;
	#5  detectors[0] = 1'b0;
end

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
	.fx2_pktend(pktend),
	.fx2_fd(fd),
	.fx2_fifoadr(fifoadr),

	.ext_clk(clk),
	.detectors(detectors),
	.laser_en(laser_en)
);

// This just prints the results in the ModelSim text window
// You can leave this out if you want
initial
	$monitor($time, "  cmd(%b %x) data(%b %x)",
		cmd_wr, cmd,
		data_avail, data
	);


/*
initial begin
	if ((4'b1111 & $random) == 4'b0)
	begin
		detectors[0] = 1'b1;
		#10 detectors[0] = 1'b0;
	end
end*/

// These statements conduct the actual circuit test
initial begin
	$display($time, "     Starting...");

	$display($time, "  Setting initial count");
	#200 ;
	#12  cmd=8'h05; cmd_wr=1;
	#12  cmd=8'h04;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h40;
	#12  cmd=8'h02;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	$display($time, "  Setting low count");
	#200 ;
	#12  cmd=8'h05; cmd_wr=1;
	#12  cmd=8'h04;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h20;
	#12  cmd=8'h04;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	$display($time, "  Setting high count");
	#200 ;
	#12  cmd=8'h05; cmd_wr=1;
	#12  cmd=8'h04;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h00;
	#12  cmd=8'h10;
	#12  cmd=8'h08;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	$display($time, "  Starting detectors");
	#200 ;
	#12  cmd=8'h01; cmd_wr=1;
	#12  cmd=8'h01;
	#12  cmd=8'h01;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);

	$display($time, "  Starting pulse sequencers");
	#200 ;
	#12  cmd=8'h01; cmd_wr=1;
	#12  cmd=8'h02;
	#12  cmd=8'h01;
	#12  cmd_wr=0; cmd_commit=1;
	#12  cmd_commit=0;
	@(cmd_sent);


	data_accepted = 1;
end

endmodule

