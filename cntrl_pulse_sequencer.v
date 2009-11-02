// Fast Multisource Pulse Registration System
// Module:
// Pulse sequencer
// (c) Ben Gamari 2009

module cntrl_pulse_sequencer(
	clk, operate,
	mask_bit, cmd_data, data_ack,
	out
);

input clk;
input operate;
input [7:0] cmd_data;
input mask_bit;
output data_ack;

output out;

wire [3:0] setting;
reg [31:0] value;

reg [3:0] state;

pulse_sequencer seq(
	.clk(clk),
	.operate(operate),
	.set_initial_state(setting[0]),
	.set_initial_count(setting[1]),
	.set_hi_count(setting[2]),
	.set_lo_count(setting[3]),
	.value(value),
	.out(out)
);

initial state = 4'b0000;

always @(posedge clk)
case (state)
	4'b0000:								// Wait until we are signalled
		if (mask_bit)
			state <= 4'b1000;
		
	4'b1000:								// Read data bytes
	begin
		value[31:24] <= cmd_data[7:0];
		state <= 4'b1001;
	end
	
	4'b1001:
	begin
		value[23:16] <= cmd_data[7:0];
		state <= 4'b1010;
	end
	
	4'b1010:
	begin
		value[15:8]  <= cmd_data[7:0];
		state <= 4'b1011;
	end
	
	4'b1011:
	begin
		value[7:0]   <= cmd_data[7:0];
		state <= 4'b1100;
	end
	
	4'b1100:								// Commit setting
		state <= 4'b0000;

endcase

assign setting[3:0] = (state == 4'b1100) ? cmd_data[3:0] : 4'b0;
assign data_ack = state[3];

endmodule
