`include "CLK_DIVIDER.v"
`include "LCD.v"
`include "CORE.v"
`include "UART.v"
`include "I2C.v"

module ASIC(reset, clock, SDA, SCL, RXD, TXD, alarma, rs_LCD, rw_LCD, EN_LCD, data_LCD, alarma_out);
	input reset;
	input clock;
	inout SDA;
	output SCL;
	input RXD;
	output TXD;
	input alarma;
	output rs_LCD;
	output rw_LCD;
	output EN_LCD;
	output [3:0] data_LCD;
	output alarma_out;
	
	wire clkI2Csel,busy_I2C, tx_busy,send_UART, rx_busy; 
        wire [1:0] clkUARTsel;
        wire [7:0] reg_I2C;
        wire busy_lcd, send_lcd,send_I2C;
	wire clk_core, clkUART, clkI2C;
	wire [7:0] lcd_bus;
	wire [7:0] add_I2C;
	wire [7:0] d_I2C;
	wire [7:0] tx_data;
	wire [7:0] rx_data;
	
	CLK_DIVIDER CLK_DIVIDER(
		.clk(clock),
  		.reset(reset),
  		.clkI2Csel(clkI2Csel),
		.clkUARTsel(clkUARTsel),
  		.clk_core(clk_core),
  		.clkI2C(clkI2C),
		.clkUART(clkUART)
  	);
	I2C I2C(
		.sda(SDA),
		.scl(SCL),
		.clk(clkI2C),
		.send(send_I2C),
		.reset(reset),
		.busy(busy_I2C),
		.add(add_I2C),
		.regis(reg_I2C),
		.dout(d_I2C)
	);
	UART UART(
		.clk(clkUART),
		.reset(reset),
		.RXD(RXD),
		.TXD(TXD),
		.tx_busy(tx_busy),
		.tx_data(tx_data),
		.send(send_UART),
		.rx_busy(rx_busy),
		.rx_data(rx_data)	
	);
	CORE CORE(
		.clk_core(clk_core),
    		.reset(reset),
    // clk_divider
    		.clkI2Csel(clkI2Csel),
    		.clkUARTsel(clkUARTsel),
  						  //I2C//
		.busy_I2C(busy_I2C),
		.add_I2C(add_I2C),
		.reg_I2C(reg_I2C),
		.din_I2C(d_I2C),
    		.ler_i2c(send_I2C),
  						  // UART
    		.tx_busy_UART(tx_busy),
		.tx_data_UART(tx_data),
   		.send_UART(send_UART),
		.rx_busy_UART(rx_busy),
		.rx_data_UART(rx_data),
   						 //LCD//
		.bus_lcd(lcd_bus),
		.busy_lcd(busy_lcd),
		.send_lcd(send_lcd),
    						// Alarme
    		.alarma(alarma),
    		.alarma_out(alarma_out)
	);
	
	LCD LCD(
		.clk(clk_core), 
		.rs_LCD(rs_LCD), 
		.rw_LCD(rw_LCD), 
		.EN_LCD(EN_LCD), 
		.data_LCD(data_LCD),
		.lcd_bus(lcd_bus), 
		.reset(reset),
		.send(send),
		.busy(busy)
	);

endmodule
