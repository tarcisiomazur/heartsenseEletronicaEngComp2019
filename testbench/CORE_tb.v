///`timescale 100ns/10ns
module core_tb();
// ---Saidas--- //
    //CLOCK//
	wire clkI2Csel;
    wire [1:0] clkUARTsel;
    //I2C//
    wire [7:0] add_I2C;
    wire [7:0] reg_I2C;
    //UART//
    wire [7:0] tx_data_UART;
    wire send_UART;
    //LCD//
    wire [7:0] bus_lcd;
    wire send_lcd;

// ---Entradas--- //
    reg clk_core;
    reg reset;
    //I2C//
    reg busy_I2C;
    reg [7:0] din_I2C;
    //UART//
    reg tx_busy_UART;
    reg rx_busy_UART;
    reg [7:0] rx_data_UART;
    //LCD//
    reg busy_lcd;
    reg alarma;

// ---Modulo--- //
core core_tb(
    //CLOCK RESET//
    .clk_core(clk_core),
    .reset(reset),
    // clk_divider
    .clkI2Csel(clkI2Csel),
    .clkUARTsel(clkUARTsel),
    //I2C//
	.busy_I2C(busy_I2C),
	.add_I2C(add_I2C),
	.reg_I2C(reg_I2C),
	.din_I2C(din_I2C),
    // UART
    .tx_busy_UART(tx_busy_UART),
	.tx_data_UART(tx_data_UART),
    .send_UART(send_UART),
	.rx_busy_UART(rx_busy_UART),
	.rx_data_UART(rx_data_UART),
    //LCD//
	.bus_lcd(bus_lcd),
	.busy_lcd(busy_lcd),
	.send_lcd(send_lcd),
    // Alarme
    .alarma(alarma),
    .alarma_out(alarma_out),
    .ler_i2c(ler_i2c)
);


initial begin
    $dumpfile("core_tb.vcd");
    $dumpvars(0, core_tb);
    clk_core=0;
	reset=1;
    //I2C//
    busy_I2C = 0;
    din_I2C = 80;
    //UART//
    tx_busy_UART = 0;
    rx_busy_UART = 0;
    rx_data_UART = 8'b00101010;
    //LCD//
    busy_lcd = 1'b0;
    alarma = 0;
#2
    reset = 0;
#2
    alarma = 1;
#4
    alarma = 0;
#4
    din_I2C = 30;
#10
    din_I2C = 80;
#20
    rx_busy_UART = 1;
#4
    rx_data_UART = 8'b00101010;
#4
    rx_busy_UART = 0;
#20
    rx_busy_UART = 1;
#4
    rx_data_UART = 8'b01010101;
#4
    rx_busy_UART = 0;
#20
    rx_busy_UART = 1;
#4
    rx_data_UART = 8'b10010101;
#4
    rx_busy_UART = 0;
#20
    rx_busy_UART = 1;
#4
    rx_data_UART = 8'b11010111;
#4
    rx_busy_UART = 0;
#20

	$finish;
    end
	
	always begin
        #1 clk_core =!clk_core;
           if(send_UART)
                tx_busy_UART=1;
            else
                tx_busy_UART=0;
           if(ler_i2c)
                busy_I2C=1;
            else
                busy_I2C=0;
            if(send_lcd)
                busy_lcd=1;
            else
                busy_lcd=0;
    end
	//initial
        //$monitor("tempo: %t,clk_core = %0d, send_UART = %0d, tx_busy_UART = %0d, tx_data_UART", $time,clk_core, send_UART,tx_busy_UART,tx_data_UART);
        /*$monitor("tempo: %t,cll = %0d, din_I2C= %0d, \n saidas: alarme= %0d, clkI2Csel = %0d, clkUARTsel = %0d, add_I2C = %0d, reg_I2C = %0d,tx_data_UART = %0d,send_UART = %0d, bus_lcd = %0d, send_lcd = %0d", $time,clk_core, din_I2C, alarma_out,clkI2Csel,clkUARTsel,add_I2C,reg_I2C,tx_data_UART,send_UART,bus_lcd,send_lcd);*/
endmodule
