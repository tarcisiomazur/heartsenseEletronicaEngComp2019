`include "receiver.v"


module receiver_tb();
	reg RXD, clk, reset;
	wire rx_busy;
	receiver r1(
		.RXD(RXD),
		.clk(clk),
		.reset(reset)
	);


	initial begin
		$dumpfile("receiver_tb.vcd");
		$dumpvars(0,receiver_tb);
		clk = 0;
		RXD = 1;
		
		//bit de inicio
		#20 RXD = 0;

		//mensagem
		#20 RXD = 0;
		#20 RXD = 1;
		#20 RXD = 0;
		#20 RXD = 1;
		#20 RXD = 0;
		#20 RXD = 1;
		#20 RXD = 0;
		#20	RXD = 1;

		//bit de fim
		#20 RXD = 1;

		#200
		$finish;
		
	end
	always #10 clk =!clk;
endmodule