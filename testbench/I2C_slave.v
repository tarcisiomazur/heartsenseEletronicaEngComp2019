module i2c_slave(scl, sda, batimento);

reg[7:0] endereco;
reg[4:0] bit_counter;
reg[7:0] registrador_lido;
reg[1:0] estado;
input batimento;
inout sda;
input scl;

initial
parameter ESPERA = 0;
parameter LENDO_ENDERECO = 1;
parameter ESCREVENDO_DADOS = 2;
parameter LENDO_DADOS = 3;
endereco <= 0;
bit_counter <= 0;
registrador_lido <= 0;

estado <= ESPERA;

end

always@ (negedge sda) 
	if (estado == ESPERA)
	begin
		bit_counter <= 0;
		estado <= LENDO_ENDERECO;
	end
end

always @(posedge scl)
	begin
		case(state):
		LENDO_ENDERECO:
			bit_counter = bit_counter+1;
			if(bit_counter == 9)
			begin
				bit_counter = 0;
				if(bits[0] == 1'b1)
					estado <= ESCREVENDO_DADOS;
				else
					estado <= LENDO_REGISTRADOR;
			end
			else
				endereco[8-bit_counter] <= sda;

		LENDO_REGISTRADOR:
			bit_counter = bit_counter +1;
			if(bit_counter == 9)
				estado <= ESPERA;

			else if(bit_counter < 9)
				registrador_lido[8-bit_counter] = sda;
		

		ESCREVENDO_DADOS:
			bit_counter = bit_counter +1;
			if(bit_counter < 9)
				sda = batimento[8-bit_counter];
			else if(bit_counter == 9)
				sda = 0;
			else if(bit_counter == 10)
				estado <= ESPERA;
	end


endmodule









module master(sda, scl, clk, reset, busy, add, reg, dout, send);

input sda;
output scl;
output [7:0] dout; // saida do batimento
input [7:0] add;  // endereço  (default: 0x0A)
input [7:0] reg;  // dado de registro   (default: 0x00)
output busy; //modo de espera, Ele que avisa pro core "tenho um dout novo, carregue"
input clk;
input reset;
input send;


reg state[2:0];  //0=enviar endereço // 1 enviar registrador // 2 receber dados// 3 enviar para o core // 4 espera 
reg bits[3:0];
reg dado;
reg rw;

parameter quantidade = 8'd150;
parameter enviar_endereço = 3'd0;
parameter enviar_registrador = 3'd1;
parameter recebimento = 3'd2;
parameter envio_core = 3'd3;
parameter espera = 3'd4;


initial begin 
	rw=0;
	dado=0;
	bits = 0;
	sda = 1;
	scl = 1;
	#5 sda = 0;
	state = 0;
End

/* colocar as máquinas de estado, utilize um case(estado) e trabalhar com cada caso
Além disso, lembrar de colocar o reset, lembre de sempre checar ele com a borda de subida do clk e jogar pro estado inicial do módulo, além disso trabalhar a parte do sub-módulo que é o slave, ele foi instanciado no código abaixo, porém não foi declarado no corpo do texto ou anteriormente, dando erro no verilog. Além disso, deve ser montado o arquivo testbench também, qualquer dúvida é só mandar que a gente tenta fazer o possível.
*/


always @(posedge send)begin
	if(state==espera)
		state=envio;
end

always @(posedge clk) begin
	if(reset==1)begin
		state=inicio;
		contador=0;
		bits = 0;
		sda = 1;
		scl = 1;
		#5 sda = 0;
		
	end
	case(state)
	inicio:
	begin
		scl=~scl;
		if(scl==1) begin	// toda subida de scl envia um bit do endereço ou do registro
			bits = bits + 1;
			if(bits<9) begin
				if(enviar_endereco)
					sda = add[8-bits];
				if(enviar_registro)
					sda = reg[8-bits];
			end
			if(bits==9)	// 9 bits enviados(ultimo deles é o ack=0), muda o envio ou passa para o próximo estágio 	
				sda=0;
			if(bits==10)
				bits=0;
				if(enviar_endereco) begin
					enviar_endereco=0;
					enviar_registro=1;
				end
				if(enviar_registro) begin
					enviar_endereco=1;
					enviar_registro=0;
					state = espera;
					sda = 1; 	// muda o estado e depois volta sda para 1; ( Começa em 1 tbm)
				end
		end
	end

	envio:
	begin
		scl=~scl;
		if(scl==1) begin	// toda subida de sda envia um bit do endereço	
			if(bits==7)
				sda=0;
			else
				sda = add[7-bits]; // envia 1 bit por vez
			bits = bits + 1;
		end
		if(scl==0&&bits==8) begin
			bits=0;
			state = recebimento;
		end
	end

	recebimento:
	begin
		scl=~scl;

		if(scl==1) begin	// toda subida de sda recebe um bit de dado
			if(bits==8)
				sda=0;
			else
				data[7-bits]=sda; // recebe 1 bit por vez
			bits = bits + 1;
			if(bits==9)begin
				state=envio_core;
				sda=1;		/// na nona subida muda estado e volta para 1
			end
		end
	
	end

	envio_core:
	begin
		if(send==1)begin
			busy=1;
			dout=data;
		end
		else begin
			busy=0;
			state = envio;
		end
	end
	
end


endmodule