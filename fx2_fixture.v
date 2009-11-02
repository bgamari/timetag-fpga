`timescale 1ns/1ns

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
wire [7:0] out_data [0:3];
wire [7:0] in_data = fd;
wire [2:0] nflags;

initial ifclk = 0;
always #6 ifclk = ~ifclk;

assign fd = sloe ? 8'bZZZZZZZZ :  // sloe is active-low
	(fifoadr == 2'b00) ? out_data[0] :
	(fifoadr == 2'b01) ? out_data[1] :
	(fifoadr == 2'b10) ? out_data[2] :
	(fifoadr == 2'b11) ? out_data[3] :
	7'bZZ;

out_fifo ep2(
	.ifclk(ifclk),
	.fifoadr(fifoadr),
	.data(out_data[0]),
	.rd(~slrd),
	.empty(nflags[0]),

	.data_in(cmd_data),
	.data_wr(cmd_wr),
	.data_commit(cmd_commit),
	.send_done(cmd_sent)
);
defparam ep2.FIFOADR = 2'b00;

in_fifo ep6(
	.ifclk(ifclk),
	.fifoadr(fifoadr),
	.data(in_data),
	.wr(~slwr),
	.full(nflags[1]),
	.pktend(~pktend)
);
defparam ep6.FIFOADR = 2'b10;

assign flags = ~nflags;

endmodule
