`default_nettype none
//////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
// "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
// output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
Gregory Kravit APPENDIX B: Verilog
94
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into
// the data bus, and the byte write enables have been combined into the
// 4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
// hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2006-Mar-08: Corrected default assignments to "vga_out_red", "vga_out_green"
// and "vga_out_blue". (Was 10'h0, now 8'h0.)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
// "disp_data_out", "analyzer[2-3]_clock" and
// "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
// actually populated on the boards. (The boards support up to
// 256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
// value. (Previous versions of this file declared this port to
// be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
// actually populated on the boards. (The boards support up to
// 72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////
module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
ac97_bit_clock,
vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
vga_out_vsync,
tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,
Gregory Kravit APPENDIX B: Verilog
95
tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,
ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b,
ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,
clock_feedback_out, clock_feedback_in,
flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
flash_reset_b, flash_sts, flash_byte_b,
rs232_txd, rs232_rxd, rs232_rts, rs232_cts,
mouse_clock, mouse_data, keyboard_clock, keyboard_data,
clock_27mhz, clock1, clock2,
disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
disp_reset_b, disp_data_in,
button0, button1, button2, button3, button_enter, button_right,
button_left, button_down, button_up,
switch,
led,
user1, user2, user3, user4,
daughtercard,
systemace_data, systemace_address, systemace_ce_b,
systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
analyzer1_data, analyzer1_clock,
analyzer2_data, analyzer2_clock,
analyzer3_data, analyzer3_clock,
analyzer4_data, analyzer4_clock);
output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
input ac97_bit_clock, ac97_sdata_in;
output [7:0] vga_out_red, vga_out_green, vga_out_blue;
Gregory Kravit APPENDIX B: Verilog
96
output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
vga_out_hsync, vga_out_vsync;
output [9:0] tv_out_ycrcb;
output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
tv_out_subcar_reset;
input [19:0] tv_in_ycrcb;
input tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
tv_in_hff, tv_in_aff;
output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
tv_in_reset_b, tv_in_clock;
inout tv_in_i2c_data;
inout [35:0] ram0_data;
output [18:0] ram0_address;
output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
output [3:0] ram0_bwe_b;
inout [35:0] ram1_data;
output [18:0] ram1_address;
output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
output [3:0] ram1_bwe_b;
input clock_feedback_in;
output clock_feedback_out;
inout [15:0] flash_data;
output [23:0] flash_address;
output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
input flash_sts;
output rs232_txd, rs232_rts;
input rs232_rxd, rs232_cts;
input mouse_clock, mouse_data, keyboard_clock, keyboard_data;
input clock_27mhz, clock1, clock2;
output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;
input disp_data_in;
output disp_data_out;
input button0, button1, button2, button3, button_enter, button_right,
button_left, button_down, button_up;
Gregory Kravit APPENDIX B: Verilog
97
input [7:0] switch;
output [7:0] led;
inout [31:0] user1, user2, user3, user4;
inout [43:0] daughtercard;
inout [15:0] systemace_data;
output [6:0] systemace_address;
output systemace_ce_b, systemace_we_b, systemace_oe_b;
input systemace_irq, systemace_mpbrdy;
output [15:0] analyzer1_data, analyzer2_data, analyzer3_data,
analyzer4_data;
output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;
////////////////////////////////////////////////////////////////////////////
//
// I/O Assignments
//
////////////////////////////////////////////////////////////////////////////
// Audio Input and Output
assign beep= 1'b0;
assign audio_reset_b = 1'b0;
assign ac97_synch = 1'b0;
assign ac97_sdata_out = 1'b0;
// ac97_sdata_in is an input
// VGA Output
assign vga_out_red = 8'h0;
assign vga_out_green = 8'h0;
assign vga_out_blue = 8'h0;
assign vga_out_sync_b = 1'b1;
assign vga_out_blank_b = 1'b1;
assign vga_out_pixel_clock = 1'b0;
assign vga_out_hsync = 1'b0;
assign vga_out_vsync = 1'b0;
// Video Output
assign tv_out_ycrcb = 10'h0;
assign tv_out_reset_b = 1'b0;
assign tv_out_clock = 1'b0;
assign tv_out_i2c_clock = 1'b0;
assign tv_out_i2c_data = 1'b0;
assign tv_out_pal_ntsc = 1'b0;
assign tv_out_hsync_b = 1'b1;
assign tv_out_vsync_b = 1'b1;
Gregory Kravit APPENDIX B: Verilog
98
assign tv_out_blank_b = 1'b1;
assign tv_out_subcar_reset = 1'b0;
// Video Input
assign tv_in_i2c_clock = 1'b0;
assign tv_in_fifo_read = 1'b0;
assign tv_in_fifo_clock = 1'b0;
assign tv_in_iso = 1'b0;
assign tv_in_reset_b = 1'b0;
assign tv_in_clock = 1'b0;
assign tv_in_i2c_data = 1'bZ;
// tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2,
// tv_in_aef, tv_in_hff, and tv_in_aff are inputs
// SRAMs
assign ram0_data = 36'hZ;
assign ram0_address = 19'h0;
assign ram0_adv_ld = 1'b0;
assign ram0_clk = 1'b0;
assign ram0_cen_b = 1'b1;
assign ram0_ce_b = 1'b1;
assign ram0_oe_b = 1'b1;
assign ram0_we_b = 1'b1;
assign ram0_bwe_b = 4'hF;
assign ram1_data = 36'hZ;
assign ram1_address = 19'h0;
assign ram1_adv_ld = 1'b0;
assign ram1_clk = 1'b0;
assign ram1_cen_b = 1'b1;
assign ram1_ce_b = 1'b1;
assign ram1_oe_b = 1'b1;
assign ram1_we_b = 1'b1;
assign ram1_bwe_b = 4'hF;
assign clock_feedback_out = 1'b0;
// clock_feedback_in is an input
// Flash ROM
assign flash_data = 16'hZ;
assign flash_address = 24'h0;
assign flash_ce_b = 1'b1;
assign flash_oe_b = 1'b1;
assign flash_we_b = 1'b1;
assign flash_reset_b = 1'b0;
assign flash_byte_b = 1'b1;
// flash_sts is an input
// RS-232 Interface
assign rs232_txd = 1'b1;
Gregory Kravit APPENDIX B: Verilog
99
assign rs232_rts = 1'b1;
// rs232_rxd and rs232_cts are inputs
// PS/2 Ports
// mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs
// // LED Displays
// assign disp_blank = 1'b1;
// assign disp_clock = 1'b0;
// assign disp_rs = 1'b0;
// assign disp_ce_b = 1'b1;
// assign disp_reset_b = 1'b0;
// assign disp_data_out = 1'b0;
// disp_data_in is an input
// Buttons, Switches, and Individual LEDs
// assign led = 8'hFF;
// button0, button1, button2, button3, button_enter, button_right,
// button_left, button_down, button_up, and switches are inputs
// User I/Os
assign user1 = 32'hZ;
assign user2 = 32'hZ;
//assign user3 = 32'hZ;
//assign user4 = 32'hZ;
// Daughtercard Connectors
assign daughtercard = 44'hZ;
// SystemACE Microprocessor Port
assign systemace_data = 16'hZ;
assign systemace_address = 7'h0;
assign systemace_ce_b = 1'b1;
assign systemace_we_b = 1'b1;
assign systemace_oe_b = 1'b1;
// systemace_irq and systemace_mpbrdy are inputs
// // Logic Analyzer
// assign analyzer1_data = 16'h0;
// assign analyzer1_clock = 1'b1;
// assign analyzer2_data = 16'h0;
// assign analyzer2_clock = 1'b1;
// assign analyzer3_data = 16'h0;
// assign analyzer3_clock = 1'b1;
// assign analyzer4_data = 16'h0;
// assign analyzer4_clock = 1'b1;
////////////////////////////////////////////////////////////////////////////
Gregory Kravit APPENDIX B: Verilog
100
//
// Reset Generation
//
// A shift register primitive is used to generate an active-high reset
// signal that remains high for 16 clock cycles after configuration finishes
// and the FPGA's internal clocks begin toggling.
//
////////////////////////////////////////////////////////////////////////////
wire reset;
SRL16 reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(reset),
.A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
defparam reset_sr.INIT = 16'hFFFF;
// use FPGA's digital clock manager to produce a
// 65MHz clock (actually 64.8MHz)
//// wire clock_50mhz_unbuf,clock_50mhz;
//// DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_50mhz_unbuf));
//// // synthesis attribute CLKFX_DIVIDE of vclk1 is 27
//// // synthesis attribute CLKFX_MULTIPLY of vclk1 is 50
//// // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
//// // synthesis attribute CLKIN_PERIOD of vclk1 is 37
//////// BUFG vclk2(.O(clock_50mhz),.I(clock_50mhz_unbuf));
wire sensor_reset, sensor_reset_debounced;
assign sensor_reset = reset | sensor_reset_debounced;
wire sensor_start;
debounce reset_debounce(.reset(reset), .clock(clock_27mhz), .noisy(~button0),
.clean(sensor_reset_debounced));
debounce sensor_start_deb(.reset(reset),.clock(clock_27mhz),
.noisy(~button3),.clean(sensor_start));
wire echo;
assign echo = user3[30];
wire trigger;
assign user3[31] = trigger;
assign user3[29:5] = 25'hZ;
wire [14:0] distance_out;
wire [14:0] distance;
wire error;
wire sensor_ready;
Gregory Kravit APPENDIX B: Verilog
101
// srf05_trigger_and_echo srf05(
// .clock(clock_27mhz), //50 MHz clock signal
// .reset(height_reset), //reset signal
// .start(height_start), //start signal to begin sensor reading
// .echo(echo), //echo read in line from sensor
// .distance(distance_out), //distance output (as a factor distance/29= cm distance)
// .trigger(trigger), //trigger line out to sensor
// .ready(sensor_ready) //when finished measuring distance
// );
srf05 height_sensor(
.clock(clock_27mhz), //50 MHz clock signal
.reset(sensor_reset), //reset signal from fpga/flight controller
// input init, //intialize signal from flight controller
.start(sensor_start), //start signal from flight controller to begin normal operation
.echo(echo), //output echo line from sensor
.distance(distance), //Kept as a factor of 29 (for centimeter height) for simplified interface (assumed signed)
.trigger(trigger), //output trigger line to sensor
.error(error), //HIGH if error is detected
.ready(sensor_ready)
);
// wire signed [15:0] distance_sync;
// synchronize16 sync_avg(.clk(clock_27mhz),.in(distance),.out(distance_sync));
// wire fir_nfd, fir_ready, fir_nd;
// assign fir_nd = sensor_ready;
// wire [15:0] fir_dout;
// wire [14:0] fir_din;
// assign fir_din = distance[14:0];
//
// fir_compiler_v5_0 fir_sr50(
// .rfd(nfd), .rdy(fir_ready), .nd(fir_nd), .clk(clock_27mhz), .dout(fir_dout), .din(fir_din));
////
//Ring Buffer
Gregory Kravit APPENDIX B: Verilog
102
reg [14:0] buffer[31:0];
reg [19:0] sum = 0;
reg [14:0] avg = 0;
reg [4:0] offset = 0;
integer i;
initial begin
for(i = 0; i < 32;i = i+1) begin
buffer[i] = 15'sd0;
end
end
always @(posedge clock_27mhz) begin
if(sensor_ready) begin
sum <= sum + (distance) - (buffer[offset]);
buffer[offset] <= distance;
offset <= offset + 1'b1;
avg <= sum/32;
end
end
//Jbimu
//hardware reset
// wire imu_reset,imu_reset_deb;
//assign imu_reset = switch[0];
// assign user4[0] = imu_reset;
wire signed [15:0] roll,pitch,yaw,roll_rate,yaw_rate,pitch_rate,accx,accy,accz;
wire [143:0] data_out2;
wire done;
wire miso,mosi,sck,ss;
assign user3[0] = sck;
assign user3[1] = sck;
assign miso = user3[2];
assign user3[3] = mosi;
assign user3[4] = ss;
assign user4[31:0] = 32'hZ;
wire [7:0] spi_data;
assign led = {1'b1, miso,switch[1],switch[2],switch[3],~sensor_reset,~sensor_start,~sensor_ready};
jb_imu imu(
.clock(clock_27mhz), //50 Mhz clock
Gregory Kravit APPENDIX B: Verilog
103
.reset(sensor_reset), //reset signal
.start(sensor_start), //start normal operations
.roll(roll), //Roll Angle *100 (deg)
.pitch(pitch), //Pitch Angle *100 (deg)
.yaw(yaw), //Yaw Angle *100 (deg)
.roll_rate(roll_rate), //Roll Rate *10 (deg/sec)
.pitch_rate(pitch_rate), //Pitch Rate *10 (deg/sec)
.yaw_rate(yaw_rate), //Yaw Rate * 10 (deg/sec)
.accel_x(accx), //Accleration gs*1000
.accel_y(accy), //Acceleration gs*1000
.accel_z(accz), //Acceleration gs*1000
.data_out_raw(data_out2),
.spi_data(spi_data),
.done(done), //IMU Finished Reading
.miso(miso), //MISO Master In/Slave Out
.mosi(mosi), //MOSI Master OUt/Slave IN
.sck(sck), //SClock out to device
.ss(ss) //SPI Select Bit
);
///AVeraging Filter for IMU outputs
//Ring Buffer
reg signed [15:0] buffer_roll[63:0];
reg signed [15:0] buffer_pitch[63:0];
reg signed [15:0] buffer_yaw[63:0];
reg signed [15:0] buffer_roll_rate[63:0];
reg signed [15:0] buffer_pitch_rate[63:0];
reg signed [15:0] buffer_yaw_rate[63:0];
reg signed [15:0] buffer_accx[63:0];
reg signed [15:0] buffer_accy[63:0];
reg signed [15:0] buffer_accz[63:0];
reg signed [21:0] sum_roll = 0;
reg signed [21:0] sum_pitch = 0;
reg signed [21:0] sum_yaw = 0;
reg signed [21:0] sum_roll_rate = 0;
reg signed [21:0] sum_pitch_rate = 0;
reg signed [21:0] sum_yaw_rate = 0;
reg signed [21:0] sum_accx = 0;
reg signed [21:0] sum_accy = 0;
reg signed [21:0] sum_accz = 0;
reg signed [15:0] avg_roll;
reg signed [15:0] avg_pitch;
reg signed [15:0] avg_yaw;
reg signed [15:0] avg_roll_rate;
reg signed [15:0] avg_pitch_rate;
reg signed [15:0] avg_yaw_rate;
Gregory Kravit APPENDIX B: Verilog
104
reg signed [15:0] avg_accx;
reg signed [15:0] avg_accy;
reg signed [15:0] avg_accz;
reg [4:0] offset2 = 0;
integer i2;
initial begin
for(i2 = 0; i2 < 64;i2 = i2+1) begin
buffer_roll[i2] = 16'sd0;
buffer_pitch[i2] = 16'sd0;
buffer_yaw[i2] = 16'sd0;
buffer_roll_rate[i2] = 16'sd0;
buffer_pitch_rate[i2] = 16'sd0;
buffer_yaw_rate[i2] = 16'sd0;
buffer_accx[i2] = 16'sd0;
buffer_accy[i2] = 16'sd0;
buffer_accz[i2] = 16'sd0;
end
end
reg [4:0] buffer_cnt = 0;
always @(posedge clock_27mhz) begin
if(done) begin
sum_roll <= sum_roll + (roll) - (buffer_roll[offset2]);
buffer_roll[offset2] <= roll;
avg_roll <= sum_roll/64;
sum_pitch <= sum_pitch + (pitch) - (buffer_pitch[offset2]);
buffer_pitch[offset2] <= pitch;
avg_pitch <= sum_pitch/64;
sum_yaw <= sum_yaw + (yaw) - (buffer_yaw[offset2]);
buffer_yaw[offset2] <= yaw;
avg_yaw <= sum_yaw/64;
sum_roll_rate <= sum_roll_rate + (roll_rate) - (buffer_roll_rate[offset2]);
buffer_roll_rate[offset2] <= roll_rate;
avg_roll_rate <= sum_roll_rate/64;
sum_pitch_rate <= sum_pitch_rate + (pitch_rate) - (buffer_pitch_rate[offset2]);
buffer_pitch_rate[offset] <= pitch_rate;
avg_pitch_rate <= sum_pitch_rate/64;
Gregory Kravit APPENDIX B: Verilog
105
sum_yaw_rate <= sum_yaw_rate + (yaw_rate) - (buffer_yaw_rate[offset2]);
buffer_yaw_rate[offset2] <= yaw_rate;
avg_yaw_rate <= sum_yaw_rate/64;
sum_accx <= sum_accx + (accx) - (buffer_accx[offset2]);
buffer_accx[offset2] <= accx;
avg_accx <= sum_accx/64;
sum_accy <= sum_accy + (accy) - (buffer_accy[offset2]);
buffer_accy[offset2] <= accy;
avg_accy <= sum_accy/64;
sum_accz <= sum_accz + (accz) - (buffer_accz[offset2]);
buffer_accz[offset2] <= accz;
avg_accz <= sum_accz/64;
end
end
wire [47:0] imu_info;
// assign imu_info = (switch[1]) ? {roll,pitch,yaw} :
// (switch[2]) ? {roll_rate,pitch_rate,yaw_rate} :
// (switch[3]) ? {accx,accy,accz} :
// 48'hFF_FF_FF_FF_FF_FF;
assign imu_info = (switch[1]) ? {avg_roll,avg_pitch,avg_yaw} :
(switch[2]) ? {avg_roll_rate,avg_pitch_rate,avg_yaw_rate} :
(switch[3]) ? {avg_accx,avg_accy,avg_accz} :
48'hFF_FF_FF_FF_FF_FF;
// assign imu_info = {roll,pitch,yaw};
wire [15:0] data_out;
assign data_out = {1'b0,avg};
//hex display out
wire [63:0] data;
assign data = {imu_info,data_out};
Gregory Kravit APPENDIX B: Verilog
106
display_16hex hexdisplay(.reset(reset),.clock_27mhz(clock_27mhz),
.data(data), .disp_blank(disp_blank),
.disp_clock(disp_clock),.disp_rs(disp_rs),
.disp_ce_b(disp_ce_b),.disp_reset_b(disp_reset_b),
.disp_data_out(disp_data_out)
);
// Logic Analyzer
assign analyzer1_data = roll;][=
assign analyzer1_clock = 1'b0;
assign analyzer2_data = 16'h0;
assign analyzer2_clock = 1'b1;
assign analyzer3_data = {3'd0,done,ss,sck,miso,mosi,spi_data};
assign analyzer3_clock = {clock_27mhz};
assign analyzer4_data = 16'h0;
assign analyzer4_clock = 1'b1;
endmodule
//
//module synchronize16 (input clk,input [15:0] in,
// output reg [15:0] out);
//
// reg [15:0] sync;
//
// always @ (posedge clk)
// begin
// {out,sync} <= {sync,in};
// end
//endmodule
module debounce #(parameter DELAY=270000) // .01 sec with a 27Mhz clock
(input reset, clock, noisy,
output reg clean);
reg [18:0] count;
reg new;
always @(posedge clock)
if (reset)
begin
count <= 0;
new <= noisy;
Gregory Kravit APPENDIX B: Verilog
107
clean <= noisy;
end
else if (noisy != new)
begin
new <= noisy;
count <= 0;
end
else if (count == DELAY)
clean <= new;
else
count <= count+1;
endmodule