`include "i2c_slave.v"
`timescale 1ns / 1ps

module i2c_slave_tb ();
	
	reg scl, batimento;
	reg sda_in;
	wire sda_out;
	i2c_slave U0(.scl(scl), .sda_in(sda_in), .sda_out(sda_out), .batimento(batimento));

	initial begin

      $dumpfile("i2c_slave.vcd");
      $dumpvars(0, i2c_slave_tb);
      scl = 1;
      sda_in = 1;

      #0.5 sda_in = 0;
      #1 sda_in = 1;
      #2 sda_in = 1;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 0;
      #2 sda_in = 1;
      #2 sda_in = 0;
      #2 sda_in = 1;
      #2 sda_in = 0;
      #2 sda_in = 1;
      #2 sda_in = 0;
      #2 sda_in = 1;
      #2 sda_in = 0;
      #2 sda_in = 1;
      #3 sda_in = 0;
      #1 sda_in = 1;
      #4 sda_in = 0;
      #10 sda_in = 1;
      #2 sda_in = 0;
      #20 sda_in = 1;
      #20;
      $finish;

   end


	always
	#1 scl = !scl;

endmodule