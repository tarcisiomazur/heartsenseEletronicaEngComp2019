`timescale 1ns / 1ps

module CLK_DIVIDER_TB();

	reg clk, reset, clkI2Csel;
	reg [1:0] clkUARTsel;
  	wire clk_core, clkI2C, clkUART;

	CLK_DIVIDER CLK_DIVIDER(
		.clk(clk),
  		.reset(reset),
  		.clkI2Csel(clkI2Csel),
		.clkUARTsel(clkUARTsel),
  		.clk_core(clk_core),
  		.clkI2C(clkI2C),
		.clkUART(clkUART)
  		);

	initial begin
		$dumpfile("CLK_DIVIDER_TB.vcd");
    		$dumpvars(0, CLK_DIVIDER_TB);
		clk = 1'b0;
		reset = 1'b0;
		clkI2Csel = 1'b0;
		clkUARTsel = 2'b11;
		#10
		clkUARTsel =2'b00;
		#300000
		clkUARTsel =2'b01;
		#300000
		clkUARTsel =2'b10;
		clkI2Csel = 1'b1;
		#300000
		clkUARTsel =2'b11;
		#300000
		reset = 1'b1;
		#100000
		$finish;

		
	end
		//clock
		always #30 clk = ~clk;
	initial 
    	$monitor("time= %t, clk= %d, clk_core=%d, clkI2C=%d, clkUART=%d, reset= %d", $time, clk, clk_core, clkI2C, clkUART, reset);
 
endmodule
