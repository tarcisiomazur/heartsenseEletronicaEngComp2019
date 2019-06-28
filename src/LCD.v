module LCD(
	clk, rs_LCD, rw_LCD, EN_LCD, data_LCD, busy, lcd_bus, reset, send);

//Declarando todas as portas de entrada

input clk;			
input [7:0] lcd_bus;						
input reset;
input send;

//Declarando todas as portas de saída

output busy;			
output rs_LCD, rw_LCD, EN_LCD;
output [3:0] data_LCD;

//Declarando os registradores internos para armazenarem as informações
reg busy;
reg [3:0] data_LCD=0;
reg rw_LCD=0;		
reg rs_LCD=0;			
reg EN_LCD=0;
		
//Parametros declarados para facilitar

parameter [7:0] FUNC_SET = 4'b0011;     
parameter [7:0] FUNC_SET_REAL1= 4'b0010;
parameter [7:0] FUNC_SET_REAL2= 8'b00101000;
parameter [7:0] CLEAR_DISPLAY = 8'b00000001; 
parameter [7:0] HOME_CURSOR = 8'b00000010;
parameter [7:0] DISPLAY_ON = 8'b00001100;
parameter [7:0] DISPLAY_OFF = 8'b00001000;
parameter [7:0] CURSOR_SHIFT = 8'b00010100; 
parameter [7:0] ENTRY_MODE = 8'b00000110; 



reg[1:0] estado = 0; //Declarando a varivel que servirá como os estados da maquina

always  @(posedge clk) begin

//A partir daqui até o estado 2 é apenas a inicialização que está descrita no
//link que o professor passou sobre o LCD

if(reset == 1'b1) begin
	estado <= 2'b00;

				//------------- POWER ON ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b0;
				busy <= 1'b1;
				data_LCD = 8'b00000000;

				#10

				//------------- FUNCTION SET #1 ---------------
				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;
				busy <= 1'b1;
				
				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET;

				#10

				//------------- FUNCTION SET #2 ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET;

				#10

				//------------- FUNCTION SET #3 ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET;

				#10

				//------------- FUNCTION SET #4 ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET;

				#10

				//------------- WAITING FOR REAL FUNCTION SET ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET_REAL1; 

				#10

				//------------- REAL FUNCTION SET (Mudou para modo 4 BITS) ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= FUNC_SET_REAL2;

				#10

				EN_LCD <= 1'b1;
				
				#10

				EN_LCD <= 1'b0;
				data_LCD <= (data_LCD >> 2); 

				#10

				//------------- DISPLAY OFF ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;
				busy <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= DISPLAY_OFF;

				#10

				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= (data_LCD >> 4); //desloca para obter os ultimos 4 bits

				#10

				//------------- CLEAR DISPLAY ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= CLEAR_DISPLAY;

				#10

				EN_LCD <= 1'b1;

				#10

				EN_LCD = 1'b0;
				data_LCD <= (data_LCD >> 4); //desloca para obter os ultimos 4 bits

				#10

				//------------- ENTRY MODE SET ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= ENTRY_MODE;

				#10

				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= (data_LCD >> 4); //desloca para obter os ultimos 4 bits

				#10

				//------------- DISPLAY ON ---------------

				rs_LCD <= 1'b0;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= DISPLAY_ON;

				#10

				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= (data_LCD << 4); //desloca para obter os ultimos 4 bits

				estado <= 2'b01;
				busy <= 1'b0;
		end

			case(estado)

			//Estado B -> Verificar se o send foi enviado do core, dessa forma pode-se
			// passar para o estado para ler os dados

			2'b01: begin
				if(send==1'b1 && busy == 1'b0) begin  
					busy <= 1'b1;
					#0.3
					estado <= 2'b10;
				end

			end

			//Estado C -> Receber dados

			2'b10: begin
				rs_LCD <= 1'b1;
				rw_LCD <= 1'b0;
				EN_LCD <= 1'b1;
				busy <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD<=lcd_bus;

				#10

				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= lcd_bus >> 4;

				#10
				EN_LCD <= 1'b1;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= CLEAR_DISPLAY;

				#10

				EN_LCD <= 1'b0;
				data_LCD <= CLEAR_DISPLAY >> 4;

				#100
				
				busy <= 1'b0;
				estado <= 2'b01;

			end
	
	endcase
end
endmodule













