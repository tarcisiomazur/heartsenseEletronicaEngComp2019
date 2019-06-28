`include "master.v"
`timescale 1ns / 100ps

module master_tb ();
	
	wire sda_out, scl;
      wire [7:0] dout;
      reg [7:0] add;
      reg [7:0] regis;
      wire busy;
      reg clk, reset, send,sda_in;
	master U0(.sda_in(sda_in), .sda_out(sda_out), .scl(scl), .clk(clk), .reset(reset), .busy(busy), .add(add), .regis(regis), .dout(dout), .send(send));

	initial begin

      $dumpfile("master.vcd");
      $dumpvars(0, master_tb);

      clk = 0;
      sda_in = 1;
      add = 8'b00001010;
      regis = 8'b10100000;
      #80 send = 1;
      #1000 reset = 1;

      $finish;

   end


	always
	#1 clk = !clk;

endmodule