`timescale 1ns/1ns

// IN (device->host) endpoint FIFO
module in_fifo(
	ifclk, fifoadr, data, slwr, pktend
);
parameter FIFOADR = 6;

input ifclk;
input slwr;
input [1:0] fifoadr;
input pktend;
output [7:0] data;

reg [7:0] buffer [1024:0];
reg [8:0] wr_idx;

always @(posedge ifclk)
begin
	if (fifoadr == FIFOADR && slwr)
	begin
		wr_idx = wr_idx + 1;
		$display("%2b OUT %x", FIFOADR, buffer[wr_idx]);
	end
	if (fifoadr == FIFOADR && pktend)
		$display("%2b: PKTEND");
end
assign data = buffer[wr_idx];
endmodule


// OUT (host->device) endpoint FIFO:
module out_fifo(
	ifclk, fifoadr, data, slrd
); 
parameter FIFOADR = 6;

input ifclk;
input slrd;
input [1:0] fifoadr;
input [7:0] data;

always @(posedge ifclk)
begin
	if (fifoadr == FIFOADR && slrd)
		$display("%2b: IN %x", fifoadr, data);
end
endmodule


// FX2 model
module fx2_test_fixture(
	ifclk, fd, slrd, slwr, flags, sloe, fifoadr, pktend
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
	.slrd(slrd)
);
defparam ep2.FIFOADR = 00;

in_fifo ep6(
	.ifclk(ifclk),
	.fifoadr(fifoadr),
	.data(in_data[2]),
	.slwr(slwr)
);
defparam ep6.FIFOADR = 10;

endmodule

