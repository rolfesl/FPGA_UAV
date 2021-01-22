`timescale 1ns / 1ps
Gregory Kravit APPENDIX B: Verilog
87
////////////////////////////////////////////////////////////////////////////////
//test_jbimu.v
module test_jbimu;
// Inputs
reg clks;
reg clock;
reg reset;
reg start;
wire miso;
// Outputs
wire [15:0] roll;
wire [15:0] pitch;
wire [15:0] yaw;
wire [15:0] roll_rate;
wire [15:0] pitch_rate;
wire [15:0] yaw_rate;
wire [15:0] accel_x;
wire [15:0] accel_y;
wire [15:0] accel_z;
wire done;
wire mosi;
wire sck;
wire ss;
// Instantiate the Unit Under Test (UUT)
jb_imu uut (
.clock(clock),
.reset(reset),
.start(start),
.roll(roll),
.pitch(pitch),
.yaw(yaw),
.roll_rate(roll_rate),
.pitch_rate(pitch_rate),
.yaw_rate(yaw_rate),
.accel_x(accel_x),
.accel_y(accel_y),
.accel_z(accel_z),
.done(done),
.miso(miso),
.mosi(mosi),
.sck(sck),
.ss(ss)
);
Gregory Kravit APPENDIX B: Verilog
88
wire slave_done;
reg [7:0] din;
wire [7:0] slave_dout;
spi_slave slave(
.clk(clks),
.rst(reset),
.ss(ss),
.mosi(mosi),
.miso(miso),
.sck(sck),
.done(slave_done),
.din(din),
.dout(slave_dout)
);
always #10 clock = ~clock; //50Mhz = 20 ns period
always #20 clks = ~clks; //25 Mhz slave clock
always @(slave_done) begin
if(slave_done) begin
din = din + 1'b1;
end
end
initial begin
// Initialize Inputs
clock = 0;
clks=0;
reset = 0;
start = 0;
din = 0;
// Wait 100 ns for global reset to finish
reset = 1;
#100;
reset = 0;
// Add stimulus here
din = 8'h00;
#20;
start = 1;
#20;
start = 0;
#10000;
end
Gregory Kravit APPENDIX B: Verilog
89
endmodule