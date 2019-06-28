 /* Módulo feito por: Pedro Henrique Brandalise da Silva Jonathan Lucas de Matos Diniz*/

`define MAX 32'd1000000
`define CLK 1
`define Fl 50
`define Fh 160
`define inicio 3'b000
`define ler_dado_uart 3'b001
`define ler_i2c 3'b010
`define enviar_LCD 3'b011
`define enviar_UART 3'b100
`define end_i2c 8'b00000000
`define regi2c 8'b01000000
`define clk12c 8'b10000000
`define clkuart 8'b11000000
`define MAXI2C 32'd500000

// ---Declaração de módulo e listagem de portas--- //

module CORE (
    // core
    clk_core,
    reset,
    // clk_divider
    clkI2Csel,
    clkUARTsel,
    // I2C_master
    busy_I2C,
    add_I2C,
    reg_I2C,
    din_I2C,
    // UART
    tx_busy_UART,
    tx_data_UART,
    send_UART,
    rx_busy_UART,
    rx_data_UART,
    // controlador_LCD
    bus_lcd,
    busy_lcd,
    send_lcd,
    // Alarme
    alarma,
    alarma_out,
    //Ler dado I2C
    ler_i2c
);

// ---Saídas--- //
    output clkI2Csel;
    output [1:0] clkUARTsel;
    output [7:0] add_I2C;
    output [7:0] reg_I2C;
    output [7:0] tx_data_UART;
    output send_UART;
    output [7:0] bus_lcd;
    output send_lcd;
    output alarma_out;
    output ler_i2c;

// ---Entradas--- //
    input clk_core;
    input reset;
    input busy_I2C;
    input [7:0] din_I2C;
    input tx_busy_UART;
    input rx_busy_UART;
    input [7:0] rx_data_UART;
    input busy_lcd;
    input alarma;

// ---Sinais internos--- //    
    reg [2:0] state;
    reg [2:0] next_state;
    reg [31:0] contador;
    reg [31:0] contadorI2C;
    reg [7:0] bpm_atual;
    reg [7:0] tx_data_UART;
    reg [1:0] clkUARTsel;
    reg clkI2Csel;
    reg [7:0] add_I2C;
    reg [7:0] reg_I2C;
    reg send_UART;
    reg [7:0] bus_lcd;
    reg send_lcd;
    reg alarma_out;
    reg [7:0]lido_uart;
    reg ler_i2c;
    reg [7:0]mascara;
    reg [7:0]concatenado;


// ---Estados--- //
always @(posedge clk_core)
begin
    if (reset) begin
        state = `inicio;
        next_state = `inicio;
        contador = 4'b0000;
        contadorI2C = 4'b0000;
        bpm_atual = 0;
        bus_lcd = 0;
        send_lcd = 0;
        send_UART  = 1'b0;
        ler_i2c = 0;
        mascara = 0;
    end else begin
        state = next_state;
    end
    if (alarma || bpm_atual > `Fh || bpm_atual < `Fl) begin
        alarma_out = 1'b1;
    end else begin
        alarma_out = 1'b0;
    end
    
    contador = contador + 1;
    contadorI2C = contadorI2C + 1;
    
    if(contador >= `MAX) begin
        contador = 4'b0000;
        send_lcd = 1'b1;
        next_state = `enviar_LCD;
    end 
    
    if (contadorI2C >= `MAXI2C) begin
        contadorI2C = 4'b0000;
        ler_i2c = 1;
        #2
        if(busy_I2C)begin
            bpm_atual <= din_I2C;
        end
        #1 ler_i2c = 0;
    end
end

always @(state or clk_core)
    case(state)
        `inicio:
        begin
            if(rx_busy_UART)
                next_state <= `ler_dado_uart;
        end
        `ler_dado_uart:
        begin
            lido_uart = rx_data_UART;
            if(!rx_busy_UART) begin            
                mascara = lido_uart & 8'b00111111;
                $display("mascara = %b",mascara);
                case(lido_uart & 8'b11000000)
                    `end_i2c:
                    begin
                       add_I2C = (mascara);
                    end
                    `regi2c:
                    begin
                        reg_I2C = (mascara);
                    end
                    `clk12c:
                    begin
                        clkI2Csel = (mascara & 1'b1);
                    end
                    `clkuart:
                    begin
                        clkUARTsel = (mascara & 2'b11);
                    end
                endcase
                next_state =`inicio;
            end else
                next_state = `ler_dado_uart;
        end
        `enviar_LCD:
        begin
            bus_lcd<=bpm_atual;            
            if(!busy_lcd) begin
                send_UART = 1'b1;
                next_state = `enviar_UART;
            end else begin
                send_lcd <= 1'b0;
                next_state = `enviar_LCD;
            end
        end
        `enviar_UART:
        begin
            tx_data_UART  = bpm_atual;
            if(!tx_busy_UART) begin
                next_state =`inicio;
            end else begin
                send_UART  = 1'b0;
                next_state =`enviar_UART;
            end
        end
        default;
    endcase
endmodule
