module CLK_DIVIDER (clk, reset, clkI2Csel, clkUARTsel, clk_core, clkI2C, clkUART);

input clk, reset, clkI2Csel;
input [1:0] clkUARTsel;
output clk_core, clkI2C, clkUART;

reg[15:0] cont_core=16'd0;
reg[15:0] cont_I2C=16'd0;
reg[15:0] cont_UART=16'd0;
parameter DIV_CORE = 16'd16;
reg[15:0] div_I2C = 16'd82;
reg[15:0] div_UART = 16'd568;

always @(posedge clk) begin
 cont_core <= cont_core + 16'd1;
 if(cont_core >= DIV_CORE)
  cont_core <= 16'd0;

 cont_I2C <= cont_I2C + 16'd1;
 if(cont_I2C >= div_I2C)
  cont_I2C <= 16'd0;
 
 cont_UART <= cont_UART + 16'd1;
 if(cont_UART >= div_UART)
  cont_UART <= 16'd0;
end

always @(clkI2Csel) begin
 div_I2C = (clkI2Csel == 0)?(16'd82):(16'd20);
end

always @(clkUARTsel) begin
 case (clkUARTsel)
    2'b00 : div_UART <= (16'd1706);
    2'b01 : div_UART <= (16'd854);
    2'b10 : div_UART <= (16'd568);
    2'b11 : div_UART <= (16'd426);
    default : div_UART <= (16'd568); 
  endcase
end

always @(reset) begin
 if(reset == 1)
  div_UART = (16'd568);
 if(reset == 1)
   div_I2C = (16'd82);
end

assign clk_core = (cont_core < (DIV_CORE/2) )?1'b0:1'b1;
assign clkI2C = (cont_I2C < (div_I2C/2) )?1'b0:1'b1;
assign clkUART = (cont_UART < (div_UART/2) )?1'b0:1'b1;

endmodule
