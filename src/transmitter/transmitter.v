module transmitter(TXD, tx_data, clk, reset, tx_busy, send);
	input [0:7]	tx_data;
	input 		send;
	input		clk;
	input		reset;
	output		TXD;
	output 		tx_busy;

	parameter waiting = 1'b0;
	parameter writing = 1'b1;
	
	reg txd_reg = 1'b1;
	reg status = waiting;

	integer count = 0;

	always @(posedge clk)
		begin
			if(reset)
				begin
					status = waiting;
					txd_reg = 1'b1;
				end
			else if(status == waiting) 
				begin
					//$display("waiting");
					if(send)
						begin
							status = writing;
							txd_reg = 1'b0;
							count = 0;
						end
				end
			else 
				begin
					//$display("writing");
					if(count<8)
						begin
							txd_reg = tx_data[count];
							count=count+1;
						end
					else
						begin
							status = waiting;
							txd_reg = 1'b1;
						end
				end
		end

	assign tx_busy = status;
	assign TXD = txd_reg;
	
endmodule
