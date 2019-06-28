module I2C(sda, scl, clk, reset, busy, add, regis, dout, send);

inout sda;
output reg scl;
output reg [7:0] dout; // saida do batimento
input [7:0] add;  // endereço  (default: 0x0A)
input [7:0] regis;  // dado de registro   (default: 0x00)
output reg busy; //modo de espera, Ele que avisa pro core "tenho um dout novo, carregue"
input clk;
input reset;
input send;

reg [2:0]state;  //0=enviar endereço // 1 enviar registrador // 2 receber dados// 3 enviar para o core // 4 espera /// 5 inicio
reg [3:0]bits;
reg [7:0]dados;
reg rw;
reg sda_rw;
reg sda_loc;

parameter enviar_endereco = 3'd0;
parameter enviar_registrador = 3'd1;
parameter recebimento = 3'd2;
parameter envio_core = 3'd3;
parameter espera = 3'd4;
parameter inicio = 3'd5;

initial begin 
	rw=0;
	dados=0;
	bits = 0;
	sda_loc = 1;
	scl = 1;
	state = 5;
	sda_rw = 0;
end

assign sda = (rw == 0 && sda_rw == 1) ? 1'bZ : sda_loc; 

always @(posedge send)begin
	if(state==espera)
		state<=enviar_endereco;
end

always @(posedge clk) begin
	if(reset==1)begin
        rw<=0;
		bits <= 0;
		dados<=0;
		sda_loc <= 1;
		sda_rw <= 0;
		scl <= 1;
		state<=inicio;
	end
	case(state)
	inicio:
    begin
        if(sda_loc==1)
            sda_loc<=0;
        else
            state<=enviar_endereco;
    end
	enviar_endereco:
	begin
	sda_rw <= 0;
		scl<=~scl;
		if(scl==1) begin	// toda subida de scl envia um bit do endereço ou do registro
			bits <= bits + 1;
			if(bits<8)
                sda_loc <= add[8-bits];
			if(bits==8)     //8 bit é o rw
                sda_loc <= rw;
			if(bits>8)begin	// 9 bits enviados(ultimo deles é o ack=0), passa para o próximo estágio 	
				sda_loc<=0;
				bits<=0;
				if(rw == 1'b0)
                	state <= enviar_registrador;
                else 
                	state <= recebimento;
                rw <= 1;       //depois que envia a o primeiro rw ele muda pra 1
            end
		end
	end

	enviar_registrador:
	begin
		scl<=~scl;
		if(scl==1) begin	// toda subida de scl envia um bit do registro
			bits <= bits + 1;
			if(bits<9)
                sda_loc <= regis[8-bits];
			if(bits==9) 	
				sda_loc<=0;  /// ack
			if(bits>9) begin  // 9 bits enviados(ultimo deles é o ack=0), passa para o próximo estágio
				bits<=0;
                state <= espera;
                sda_loc <= 1; 	// muda o estado e depois volta sda para 1; ( Começa em 1 tbm)
            end
		end
	end

	recebimento:
	begin
		sda_rw <= 1;
		scl<=~scl;
		if(scl==1) begin	// toda subida de sda recebe um bit de dado
			bits <= bits + 1;
			if(bits<9)begin
			    dados[8-bits]<=sda;
			end
			if(bits>9)begin
				state<=envio_core;
				sda_loc<=1;		/// na décima subida muda estado e volta para 1
			end
		end
	end

	envio_core:
	begin
		if(send==1)begin
			busy<=1;
			dout<=dados;
		end
		else begin
			busy<=0;
			state <= espera;
		end
	end
	endcase
	
end


endmodule
