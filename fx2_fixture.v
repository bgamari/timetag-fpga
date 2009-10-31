// FX2 model
module fx2_test_fixture(
	ifclk, fd, slrd, slwr, sloe, fifoadr, pktend, flags,

	// "Host" interface
	cmd_data, cmd_wr, cmd_commit, cmd_sent
);

output ifclk;
input slrd;
input slwr;
input sloe;
input [1:0] fifoadr;
input pktend;
output [2:0] flags;
inout [7:0] fd;

input [7:0] cmd_data;
input cmd_wr, cmd_commit;
output cmd_sent;

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
	.empty(flags[0]),

	.data_in(cmd_data),
	.data_wr(cmd_wr),
	.commit(cmd_commit),
	.send_done(cmd_sent)
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
