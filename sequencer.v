`include "config.v"
module seq_channel(
	clk,
	reset, operate,
	out,
	reg_clk, reg_addr, reg_data, reg_wr
);
parameter REGBASE = 0;

input clk;
input reset;
input operate;

output out;

input reg_clk;
input [15:0] reg_addr;
inout [31:0] reg_data;
input reg_wr;

reg out;
initial out = 0;
reg [31:0] counter;
initial counter = 32'h0;

wire [31:0] config_value;
wire enabled = config_value[0];
wire initial_state = config_value[1];
register #(.ADDR(REGBASE+0)) config_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(config_value)
);
wire [31:0] initial_count;
register #(.ADDR(REGBASE+1)) initial_count_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(initial_count)
);
wire [31:0] low_count;
register #(.ADDR(REGBASE+2)) low_count_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(low_count)
);
wire [31:0] high_count;
register #(.ADDR(REGBASE+3)) high_count_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(high_count)
);

always @(posedge clk && enabled && operate)
begin
	if (reset)
	begin
		out <= initial_state;
		counter <= initial_count;
	end
	else if (counter == 0)
	begin
		out <= !out;
		counter <= out ? low_count : high_count;
	end
	else
		counter <= counter - operate;
end
endmodule


module sequencer(
	clk,
	outputs,
	reg_clk, reg_addr, reg_data, reg_wr
);

input clk;

output [3:0] outputs;

input reg_clk;
input [15:0] reg_addr;
inout [31:0] reg_data;
input reg_wr;

wire [31:0] config_value;
wire operate = config_value[0];
wire reset = config_value[1];
register #(.ADDR(8'h20)) config_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.clk(clk),
	.value(config_value)
);

readonly_register #(.ADDR(8'h21)) clockrate_reg(
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr),
	.value(`SEQ_CLOCKRATE)
);

seq_channel #(.REGBASE(8'h28)) seq_ch0(
	.clk(clk),
	.reset(reset),
	.operate(operate),
	.out(outputs[0]),
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

seq_channel #(.REGBASE(8'h30)) seq_ch1(
	.clk(clk),
	.reset(reset),
	.operate(operate),
	.out(outputs[1]),
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

seq_channel #(.REGBASE(8'h38)) seq_ch2(
	.clk(clk),
	.reset(reset),
	.operate(operate),
	.out(outputs[2]),
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

seq_channel #(.REGBASE(8'h40)) seq_ch3(
	.clk(clk),
	.reset(reset),
	.operate(operate),
	.out(outputs[3]),
	.reg_clk(reg_clk),
	.reg_addr(reg_addr),
	.reg_data(reg_data),
	.reg_wr(reg_wr)
);

endmodule

