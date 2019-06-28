`include "transmitter.v"


module transmitter_tb();
	reg clk, tx_data, reset, send;
	wire tx_busy;

	transmitter t1(
		.tx_data(8'b00010001),
		.clk(clk),
		.reset(1'b0),
		.send(send)
	);

	initial begin
		$dumpfile("transmitter_tb.vcd");
		$dumpvars(0,transmitter_tb);
		clk = 0;
		#20 send = 1;

		#20 send = 0;
		#200
		$finish;
	end

	always #10 clk =!clk;

endmodule