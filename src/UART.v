`include "transmitter/transmitter.v"
`include "receiver/receiver.v"
module UART(RXD, TXD, clk, rx_data, tx_data, reset, send, rx_busy, tx_busy);
	input	RXD;
	input	clk;
	input	reset;
	output	[0:7] rx_data;
	output	rx_busy;
	input [0:7]	tx_data;
	input 		send;
	output		TXD;
	output 		tx_busy;

	transmitter t1(
		.tx_data(tx_data),
		.clk(clk),
		.reset(reset),
		.tx_busy(tx_busy),
		.send(send),
		.TXD(TXD)
	);

	receiver r1(
		.RXD(RXD),
		.clk(clk),
		.reset(reset),
		.rx_data(rx_data),
		.rx_busy(rx_busy)
	);


	

endmodule
