`timescale 1ns/1ns

// IN (device->host) endpoint FIFO
module in_fifo(
	ifclk, fifoadr, data, wr, pktend, full,

	// "Host" interface
	recvd_data, recvd_rdy
);
	parameter FIFOADDR = 2'b00;

	// FPGA interface
	input ifclk;
	input wr;
	input [1:0] fifoadr;
	input pktend;
	input [7:0] data;
	output full;

	// "Host" interface
	output [7:0] recvd_data;
	output recvd_rdy;

	reg [31:0] outf;
	initial
		outf = $fopen("data.out", "w");

	always @(posedge ifclk)
	begin
		if ((fifoadr == FIFOADDR) && wr)
		begin
			//$display($time, "  %2b: IN %x", FIFOADDR, data);
			$fwrite(outf, "%02x\n", data);
		end
		if ((fifoadr == FIFOADDR) && pktend)
			$display($time, "  %2b: PKTEND", FIFOADDR);
	end

	assign full = 0;
	assign recvd_data = data;
	assign recvd_rdy = wr && (fifoadr == FIFOADDR);
endmodule


// OUT (host->device) endpoint FIFO:
module out_fifo(
	ifclk, fifoadr, data, rd, empty,

	// "Host" interface
	data_in, data_wr, data_commit, send_done
); 
	parameter FIFOADDR = 2;
	parameter EMPTY_LEVEL = 1;

	// FPGA interface
	input ifclk;
	input rd;
	input [1:0] fifoadr;
	output [7:0] data;
	output empty;

	// "Host" interface
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
		if ((fifoadr == FIFOADDR) && rd && data_waiting)
		begin
			tail <= tail + 1;
			//$display($time, "  %2b: OUT %x", fifoadr, data);
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


// FX2 test fixture: Simulate an FX2
module fx2_test_fixture(
	ifclk, fd, slrd, slwr, sloe, fifoadr, pktend, flags,

	// "Host" interface
	cmd_data, cmd_wr, cmd_commit, cmd_sent,
	reply_data, reply_rdy,
	data, data_rdy
);

	output ifclk;
	input slrd, slwr, sloe;
	input [1:0] fifoadr;
	input pktend;
	output [2:0] flags;
	inout [7:0] fd;

	// "Host" interface
	input [7:0] cmd_data;
	input cmd_wr, cmd_commit;
	output cmd_sent;

	output [7:0] reply_data;
	output reply_rdy;

	output [7:0] data;
	output data_rdy;
	
	// Internal
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

	// Command FIFO
	out_fifo #(.FIFOADDR(2'b00)) ep2(
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

	// Data FIFO
	in_fifo #(.FIFOADDR(2'b10)) ep6(
		.ifclk(ifclk),
		.fifoadr(fifoadr),
		.data(in_data),
		.wr(~slwr),
		.full(nflags[1]),
		.pktend(~pktend),

		.recvd_data(data),
		.recvd_rdy(data_rdy)
	);

	// Reply FIFO
	in_fifo #(.FIFOADDR(2'b11)) ep8(
		.ifclk(ifclk),
		.fifoadr(fifoadr),
		.data(in_data),
		.wr(~slwr),
		.full(nflags[2]),
		.pktend(~pktend),

		.recvd_data(reply_data),
		.recvd_rdy(reply_rdy)
	);

	assign flags = ~nflags;
endmodule
