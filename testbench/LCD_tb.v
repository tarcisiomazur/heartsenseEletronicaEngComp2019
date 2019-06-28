module LCD_tb();

reg CLK;			
reg [7:0] DATA;						
reg reset;
reg send;

wire busy;			
wire rs, rw, enable;
wire [3:0] dataBus;

LCD U0(
.clk(CLK), 
.rs_LCD(rs), 
.rw_LCD(rw), 
.EN_LCD(enable), 
.data_LCD(dataBus),
.lcd_bus(DATA), 
.reset(reset), 
.send(send),
.busy(busy)
);

initial begin
$dumpfile("lcd_tb.vcd");
$dumpvars(0, LCD_tb);

CLK <= 1'b0;
reset <= 1'b1;
#10
reset <= 1'b0;
send <= 1'b1;
DATA <= 8'b00101111;

//fim inicialização

#420
send <= 1'b0;

#50
send <= 1'b1;
DATA <= 8'h82;

#100
send<=1'b0;
DATA <= 8'h53;

#100
send<=1'b1;

#100









$finish;
end

always #10 CLK =!CLK;

initial
$monitor("tempo: %t, CLK: %d, lcd_bus : %d , data_LCD: %d, rs: %d, rw: %d, enable: %d, send: %d, reset: %d, busy: %d", $time, CLK, DATA, dataBus, rs, rw, enable, send, reset, busy);

endmodule
