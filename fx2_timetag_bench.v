`timescale 1ns/1ns

module fx2_timetag_bench();

reg clk;
wire fx2_clk;
wire [7:0] fd;
reg slrd;
reg slwr;
reg sloe;
reg pktend;
wire [3:0] flags;


wire [15:0] length;
reg request_length;


wire [7:0] data;
wire data_avail;
reg data_accepted;

reg [3:0] detectors;
wire [3:0] laser_en;
wire running;


// External Clock
initial clk = 0;
always #2 clk = ~clk;

// Simulate photons
initial detectors = 4'b0000;
always begin
	#100 detectors[0] = 1'b1;
	#5  detectors[0] = 1'b0;
end

// FX2 model
module fx2_test_fixture(
	ifclk, fd, slrd, slwr, sloe, fifoadr, pktend, flags,
	cmd_data, cmd_data_wr, cmd_data_commit, cmd_data_sent
);

output ifclk;
input slrd;
input slwr;
input sloe;
input [1:0] fifoadr;
input pktend;
input [3:0] flags;
inout [7:0] fd;

reg ifclk;
wire [7:0] in_data [0:3];
wire [7:0] out_data = fd;

initial ifclk = 0;
always #6 ifclk = ~ifclk;

assign fd = ~sloe ? 8'bZZZZZZZZ : 
	(fifoadr == 2'b00) ? in_data[0] :
	(fifoadr == 2'b01) ? in_data[1] :
	(fifoadr == 2'b10) ? in_data[2] :
	(fifoadr == 2'b11) ? in_data[3] :
	7'b0;

out_fifo ep2(
	.ifclk(ifclk),
	.fifoadr(fifoadr),
	.data(out_data),
	.slrd(slrd),
	.empty(flags[0])
);
defparam ep2.FIFOADR = 00;

in_fifo ep6(
	.ifclk(ifclk),
	.fifoadr(fifoadr),
	.data(in_data[2]),
	.slwr(slwr),
	.full(flags[1])
);
defparam ep6.FIFOADR = 10;

endmodule

fx2_test_fixture fx2(
	.ifclk(fx2_clk),
	.fd(fd),
	.slrd(slrd),
	.slwr(slwr),
	.sloe(sloe),
	.fifoadr(fifoadr),
	.pktend(pktend),
	.flags(flags),
	
	.ext_clk(clk),
	.detectors(detectors)
);

// Instantiate the UUT
fx2_timetag uut(
	.fx2_clk(fx2_clk),
	.fx2_flags(flags),
	.fx2_SLWR(slwr),
	.fx2_SLRD(slrd),
	.fx2_SLOE(sloe),
	.fx2_PKTEND(pktend),
	.fx2_FD(fd),
	.fx2_FIFOADR(fifoadr),

	.clk(clk),
	.detectors(detectors),
	.laser_en(laser_en),
	.running(running)
);

// This just prints the results in the ModelSim text window
// You can leave this out if you want
initial
	$monitor($time, "  cmd(%b %x) data(%b %x) cmd_avail=%b cmd_ack=%b cmd_data=%x state=",
		cmd_wr, cmd_in,
		data_avail, data,
		uut.cmd_avail, uut.cmd_ack, uut.cmd_data, uut.cmd_parser.state
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
	#100 ;
	#12  cmd_in=8'h05; cmd_wr=1;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h40;
	#12  cmd_in=8'h02;
	#12  cmd_wr=0;

	$display($time, "  Setting low count");
	#100 ;
	#12  cmd_in=8'h05; cmd_wr=1;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h20;
	#12  cmd_in=8'h04;
	#12  cmd_wr=0;

	$display($time, "  Setting high count");
	#100 ;
	#12  cmd_in=8'h05; cmd_wr=1;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h10;
	#12  cmd_in=8'h08;
	#12  cmd_wr=0;

	$display($time, "  Starting detectors");
	#100 ;
	#12  cmd_in=8'h01; cmd_wr=1;
	#12  cmd_in=8'h01;
	#12  cmd_in=8'h01;
	#12  cmd_wr=0;

	$display($time, "  Starting pulse sequencers");
	#100 ;
	#12  cmd_in=8'h01; cmd_wr=1;
	#12  cmd_in=8'h02;
	#12  cmd_in=8'h01;
	#12  cmd_wr=0;


	data_accepted = 1;
end

endmodule

