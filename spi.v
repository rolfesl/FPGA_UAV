`timescale 1ns / 1ps
//Gregory Kravit
// gkravit@mit.edu
//Adapted from embeddedmicro.com
//////////////////////////////////////////////////////////////////////////////////
// SPI Master: Mode 0 CKE = 1; CKP = 0;
//Sources Used:
// http://www.rosseeld.be/DRO/PIC/SPI_Timing.htm
// http://www.elecdude.com/2013/09/spi-master-slave-verilog-code-spi.html
// dsPIC (JBimu Microcontroller) p. 372
//
//Mode 0
// Parameters:
// SPI_CLK_DIV:
// -Divides System Clock for relevant SCK speed
// SPI_CLK_DIV = C: SCK_FREQ = CLK_FREQ/2^C
// C = 2: SCK_FREQ = CLK_FREQ /4
// 3: SCK_FREQ = CLK_FREQ /8
// 4: SCK_FREQ = CLK_FREQ /16

80
// 5: SCK_FREQ = CLK_FREQ /32
// SPI_BUS_WIDTH:
// -Number of Bits In Communication expected to transmit and receive
// SPI_BUS_WIDTH = W:
//////////////////////////////////////////////////////////////////////////////////
module spi #(parameter SPI_CLK_DIV = 4, parameter SPI_BUS_WIDTH = 8)(
input clk,
input rst,
input miso,
output mosi,
output sck,
input start,
input [SPI_BUS_WIDTH-1:0] data_in,
output[SPI_BUS_WIDTH-1:0] data_out,
output ss,
output busy,
output new_data
);
//num bits needed to count to bus width
localparam NUM_BITS = log2(SPI_BUS_WIDTH);
localparam STATE_SIZE = 2;
localparam IDLE = 2'd0,
WAIT_HALF = 2'd1,
TRANSFER = 2'd2;
reg [STATE_SIZE-1:0] state_d, state_q;
reg [SPI_BUS_WIDTH-1:0] data_d, data_q;
reg [SPI_CLK_DIV-1:0] sck_d, sck_q;
// wire sck_old;
reg mosi_d, mosi_q;
reg [NUM_BITS-1:0] ctr_d, ctr_q;
reg new_data_d, new_data_q;
reg [7:0] data_out_d, data_out_q;
assign mosi = mosi_q;
assign ss = state_q == IDLE;
assign sck = (sck_q[SPI_CLK_DIV-1]) & (state_q == TRANSFER);
assign busy = state_q != IDLE;
assign data_out = data_out_q;
assign new_data = new_data_q;
always @(*) begin
sck_d = sck_q;

81
data_d = data_q;
mosi_d = mosi_q;
ctr_d = ctr_q;
new_data_d = 1'b0;
data_out_d = data_out_q;
state_d = state_q;
case (state_q)
IDLE: begin
sck_d = 4'b0;
ctr_d = 3'b0;
mosi_d = 1'b1;
if (start == 1'b1) begin
data_d = data_in;
state_d = WAIT_HALF;
end
end
WAIT_HALF: begin
sck_d = sck_q + 1'b1;
if (sck_q == {1'b0,{SPI_CLK_DIV-1{1'b1}}}) begin
sck_d = 1'b0; //go right to transfer
state_d = TRANSFER;
end
end
TRANSFER: begin
sck_d = sck_q + 1'b1;
if (sck_q == 0) begin //transmit on falling edge
mosi_d = data_q[7];
end else if (sck_q == {1'b0,{SPI_CLK_DIV-1{1'b1}}}) begin //sample on rising edge
data_d = {data_q[6:0], miso};
end else if (sck_q == {SPI_CLK_DIV{1'b1}}) begin // change bits between sck
ctr_d = ctr_q + 1'b1;
if (ctr_q == {NUM_BITS-1{1'b1}}) begin
state_d = IDLE;
data_out_d = data_q;
new_data_d = 1'b1;
end
end
end
endcase
end
always @(posedge clk) begin
if (rst) begin
ctr_q <= {NUM_BITS-1{1'b0}};
data_q <= {SPI_BUS_WIDTH{1'b0}};

82
sck_q <= {SPI_CLK_DIV{1'b0}};
mosi_q <= 1'b1;
state_q <= IDLE;
data_out_q <= {SPI_BUS_WIDTH{1'b0}};
new_data_q <= 1'b0;
end else begin
ctr_q <= ctr_d;
data_q <= data_d;
sck_q <= sck_d;
mosi_q <= mosi_d;
state_q <= state_d;
data_out_q <= data_out_d;
new_data_q <= new_data_d;
end
end
function integer log2;
input [31:0] value;
begin
for (log2=0; value>0; log2=log2+1)
begin
value = value>>1;
end
end
endfunction
endmodule