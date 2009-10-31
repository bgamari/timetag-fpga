`timescale 1ns/1ns

// IN (device->host) endpoint FIFO
module in_fifo(
	ifclk, fifoadr, data, slwr, pktend, full
);
parameter FIFOADR = 6;

input ifclk;
input slwr;
input [1:0] fifoadr;
input pktend;
output [7:0] data;

always @(posedge ifclk)
begin
	if (fifoadr == FIFOADR && slwr)
		$display("%2b IN %x", FIFOADR, buffer[tail]);
	if (fifoadr == FIFOADR && pktend)
		$display("%2b: PKTEND");
end

assign full = 0;
assign data = buffer[tail];
endmodule


// OUT (host->device) endpoint FIFO:
module out_fifo(
	ifclk, fifoadr, data, slrd, empty
	data_in, data_in_wr, commit, send_done
); 
parameter FIFOADR = 2;

input ifclk;
input slrd;
input [1:0] fifoadr;
input [7:0] data;
output empty;

input [7:0] data_in;
input data_in_wr;
input commit;
output send_done;

reg [7:0] buffer [1024:0];
reg [8:0] staged_length;
reg [8:0] length; // Amount of data in buffer
reg [8:0] tail; // Read-out index
reg [8:0] head; // Read-in index
reg send_done;

always @(posedge ifclk)
begin
	if (fifoadr == FIFOADR && slrd && length)
	begin
		head <= head + 1;
		$display("%2b: OUT %x", fifoadr, data);
	end

	if (send_done)
	begin
		length <= 0;
		head <= 0;
		tail <= 0;
	end
end

always @(posedge ifclk)
begin
	if (data_wr)
	begin
		buffer[tail] <= data;
		staged_length <= staged_length + 1;
		tail <= tail + 1;
	end

	if (commit)
	begin
		length = staged_length;
		staged_length <= 0;
	end
end

assign data = buffer[tail];
assign send_done = (head == length) && (length != 0);
assign empty = (length == 0);
endmodule


// FX2 model
module fx2_test_fixture(
	ifclk, fd, slrd, slwr, sloe, fifoadr, pktend, flags
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

