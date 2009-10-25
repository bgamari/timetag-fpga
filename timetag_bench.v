// set time scale
`timescale 1ns/1ns

module timetag_bench();

reg clk;
reg fx2_clk;

reg cmd_wr;
reg [7:0] cmd_in;

wire [15:0] length;
reg request_length;


wire [7:0] data;
wire data_avail;
reg data_accepted;

reg [3:0] detectors;
wire [3:0] laser_en;
wire running;

// Bidirs

// Instantiate the UUT
timetag uut(
	.fx2_clk(fx2_clk),
	.request_length(request_length),
	.length(length),
	.data_avail(data_avail),
	.data(data),
	.data_accepted(data_accepted),
	.cmd_wr(cmd_wr),
	.cmd_in(cmd_in),
	
	.clk(clk),
	.detectors(detectors),
	.laser_en(laser_en),
	.running(running)
);

// This just prints the results in the ModelSim text window
// You can leave this out if you want
initial
begin
	//$monitor($time, "A=%b,B=%b, c_in=%b, c_out=%b, sum = %b\n",A,B,C0,C4,S);
end

// Clocks
always #2 clk = ~clk;
always #6 fx2_clk = ~fx2_clk;

// Simulate photons
initial detectors = 4'b0000;
always begin
	if (4'b1111 == $random) begin
		detectors[0] = 1'b1;
		#10 detectors[0] = 1'b0;
	end
end

// These statements conduct the actual circuit test
initial begin
	// Set initial count
	#100 ;
	#2  cmd_in=8'h05; cmd_wr=1;
	#2  cmd_in=8'h04;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h40;
	#2  cmd_in=8'h02;
	#2  cmd_wr=0;

	// Set low count
	#100 ;
	#2  cmd_in=8'h05; cmd_wr=1;
	#2  cmd_in=8'h04;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h20;
	#2  cmd_in=8'h04;
	#2  cmd_wr=0;

	// Set high count
	#100 ;
	#2  cmd_in=8'h05; cmd_wr=1;
	#2  cmd_in=8'h04;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h00;
	#2  cmd_in=8'h10;
	#2  cmd_in=8'h08;
	#2  cmd_wr=0;

	// Start detectors
	#100 ;
	#2  cmd_in=8'h01; cmd_wr=1;
	#2  cmd_in=8'h01;
	#2  cmd_in=8'h01;
	#2  cmd_wr=0;

	// Start pulse sequencers
	#100 ;
	#2  cmd_in=8'h01; cmd_wr=1;
	#2  cmd_in=8'h02;
	#2  cmd_in=8'h01;
	#2  cmd_wr=0;
end

endmodule

