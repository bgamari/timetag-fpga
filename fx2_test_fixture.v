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
