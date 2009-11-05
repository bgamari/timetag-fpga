`timescale 1ns/1ns

// IN (device->host) endpoint FIFO
module in_fifo(
	ifclk, fifoadr, data, wr, pktend, full
);
parameter FIFOADR = 2'b00;

input ifclk;
input wr;
input [1:0] fifoadr;
input pktend;
input [7:0] data;
output full;

reg [31:0] outf;
initial
	outf = $fopen("data.out", "w");

always @(posedge ifclk)
begin
	if ((fifoadr == FIFOADR) && wr)
	begin
		$display("%2b: IN %x", FIFOADR, data);
		$fwrite(outf, "%02x\n", data);
	end
	if ((fifoadr == FIFOADR) && pktend)
		$display("%2b: PKTEND", FIFOADR);
end

assign full = 0;
endmodule


// OUT (host->device) endpoint FIFO:
module out_fifo(
	ifclk, fifoadr, data, rd, empty,

	// "Host" interface
	data_in, data_wr, data_commit, send_done
); 
parameter FIFOADR = 2;
parameter EMPTY_LEVEL = 1;

input ifclk;
input rd;
input [1:0] fifoadr;
output [7:0] data;
output empty;

input [7:0] data_in;
input data_wr;
input data_commit;
output send_done;

reg [7:0] buffer [1024:0];
reg [8:0] length; // Amount of data in buffer
reg [8:0] tail; // Read-out index
reg [8:0] head; // Read-in index

wire data_waiting = (length != 0);
wire send_done = (tail == length) && data_waiting;
wire empty = ((length-tail) <= EMPTY_LEVEL);


initial length = 0;
initial tail = 0;
initial head = 0;

always @(posedge ifclk)
begin
	if ((fifoadr == FIFOADR) && rd && data_waiting)
	begin
		tail <= tail + 1;
		$display("%2b: OUT %x", fifoadr, data);
	end

	if (send_done)
	begin
		length <= 0;
		tail <= 0;
	end
end

always @(posedge ifclk)
begin
	if (data_wr)
	begin
		buffer[head] <= data_in;
		head <= head + 1;
	end

	if (data_commit)
	begin
		length <= head;
		head <= 0;
	end
end

assign data = data_waiting ? buffer[tail] : 8'hZZ;

endmodule

