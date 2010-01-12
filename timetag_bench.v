`timescale 1ns/1ns

module timetag_bench();

reg clk;
reg fx2_clk;

reg cmd_wr;
reg [7:0] cmd_in;

wire [15:0] length;
reg request_length;


wire [7:0] data;
wire data_rdy;
reg data_ack;

reg [3:0] detectors;
wire [3:0] laser_en;
wire running;

// Bidirs

// Instantiate the UUT
timetag uut(
	.fx2_clk(fx2_clk),
	.cmd_wr(cmd_wr),
	.cmd_in(cmd_in),

	.clk(clk),
	.detectors(detectors),
	.laser_en(laser_en),

	.data_rdy(data_rdy),
	.data(data),
	.data_ack(data_ack)
);

// This just prints the results in the ModelSim text window
// You can leave this out if you want
initial
	$monitor($time, "  cmd(%b %x) data(%b %x) cmd_rdy=%b cmd_ack=%b cmd_data=%x state=",
		cmd_wr, cmd_in,
		data_rdy, data,
		uut.cmd_rdy, uut.cmd_ack, uut.cmd, uut.cmd_parser.state
	);

// Clocks
initial clk = 0;
always #2 clk = ~clk;
initial fx2_clk = 0;
always #6 fx2_clk = ~fx2_clk;

// Simulate photons
initial detectors = 4'b0000;
//`define RANDOM_PHOTONS
`ifdef RANDOM_PHOTONS
initial begin
	if ((4'b1111 & $random) == 4'b0)
	begin
		detectors[0] = 1'b1;
		#10 detectors[0] = 1'b0;
	end
end
`else
always begin
	#100 detectors[0] = 1'b1;
	#5  detectors[0] = 1'b0;
end
`endif


// These statements conduct the actual circuit test
initial begin
	$display($time, "     Starting...");

	$display($time, "  Setting initial count");
	#100 ;
	#12  cmd_in=8'hAA; cmd_wr=1;
	#12  cmd_in=8'h05;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h40;
	#12  cmd_in=8'h02;
	#12  cmd_wr=0;

	$display($time, "  Setting low count");
	#100 ;
	#12  cmd_in=8'hAA; cmd_wr=1;
	#12  cmd_in=8'h05;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h20;
	#12  cmd_in=8'h04;
	#12  cmd_wr=0;

	$display($time, "  Setting high count");
	#100 ;
	#12  cmd_in=8'hAA; cmd_wr=1;
	#12  cmd_in=8'h05;
	#12  cmd_in=8'h04;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h00;
	#12  cmd_in=8'h10;
	#12  cmd_in=8'h08;
	#12  cmd_wr=0;

	$display($time, "  Starting detectors");
	#100 ;
	#12  cmd_in=8'hAA; cmd_wr=1;
	#12  cmd_in=8'h01;
	#12  cmd_in=8'h01;
	#12  cmd_in=8'h01;
	#12  cmd_wr=0;

	$display($time, "  Starting pulse sequencers");
	#100 ;
	#12  cmd_in=8'hAA; cmd_wr=1;
	#12  cmd_in=8'h01;
	#12  cmd_in=8'h02;
	#12  cmd_in=8'h01;
	#12  cmd_wr=0;

	data_ack = 1;
end

endmodule

