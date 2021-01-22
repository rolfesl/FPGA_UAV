`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Module Name: flight_control_initialize
//////////////////////////////////////////////////////////////////////////////////
module flight_control_initialize(
input clock, //clock
input reset, //reset initialize
input start, //start initialization
output done, //indicates initialization is done
output reg error_srf05,
output reg error_imu,
output reset_1sec, //reset 1 sec divider
input en_sec, //divider signal from 1 second divider
input calibrate, //if high, calibrate motors
output reg [31:0] throttles, //throttle settings for motors
output reg motors_start, //start motor controller
output reg motors_reset, //reset motor controller
output reg srf05_start, //start height sensor
output reg srf05_reset, //reset height sensor
input srf05_new_data,
input [14:0] distance, //height reading from sensor (in microseconds)
output reg [14:0] offset_distance, //offset initial height reading (in microseconds)
output reg imu_start, //start imu signal
output reg imu_reset, //reset imu signal
input imu_new_data, //new data available
input signed [15:0] cur_roll, //roll angle: sensor reading from imu

50
input signed [15:0] cur_pitch, //pitch angle: sensor reading from imu
input signed [15:0] cur_yaw, //yaw angle: sensor reading from imu
input signed [15:0] cur_roll_rate, //roll rate: sensor reading from imu
input signed [15:0] cur_pitch_rate, //pitch rate: sensor reading from imu
input signed [15:0] cur_yaw_rate, //yaw rate: sensor reading from imu
output reg signed [15:0] offset_roll, //roll angle: offset for control arithmetic
output reg signed [15:0] offset_pitch, //pitch angle: offset for control arithmetic
output reg signed [15:0] offset_yaw, //yaw angle: offset for control arithmetic
output reg signed [15:0] offset_roll_rate, //roll rate: offset for control arithmetic
output reg signed [15:0] offset_pitch_rate, //pitch rate: offset for control arithmetic
output reg signed [15:0] offset_yaw_rate //yaw rate: offset for control arithmetic
);
//Initialization Steps
// 1. Calibrate Motors (if enabled)
// -Throttle High
// -Throttle Idle
//
// 2. Start Range Sensor
// -Check no error recorded
// -Averaging Filter
// -Record Initial Value
// 3. Start IMU Board
// -Record Initial Values for 5 seconds
// -Averaging Filter
// -Record Offset Values
// Spin Rotors for Confirmation
reg [4:0] state, next_state;
localparam RESET = 4'd0;
localparam ERROR_SRF05 = 4'd1, ERROR_IMU = 4'd2;
localparam CALIBRATE = 4'd3,
CALIBRATE_COMPLETE = 4'd4;
localparam RANGE_SENSOR1 = 4'd5,
RANGE_SENSOR2 = 4'd6,
RANGE_SENSOR3 = 4'd7;
localparam IMU1 = 4'd8,
IMU2 = 4'd9,

51
IMU3 = 4'd10;
localparam END1 = 4'd11,
END2 = 4'd12;
localparam DONE = 4'd13;
assign done = (state == DONE);
reg [3:0] timer_q, timer_d;
assign reset_1sec = (state != next_state);
//Ring Buffer for SRF05-Range Sensor
reg [14:0] buffer_dist[31:0];
reg [19:0] sum_dist = 0;
reg [14:0] avg_dist = 0;
reg [5:0] index = 0;
integer i;
// initial begin
// for(i = 0; i < 32;i = i+1) begin
// buffer_dist[i] = 15'd0;
// end
// end
//Ring Buffer for
///AVeraging Filter for IMU outputs
//Ring Buffer
reg signed [15:0] buffer_roll[63:0];
reg signed [15:0] buffer_pitch[63:0];
reg signed [15:0] buffer_yaw[63:0];
reg signed [15:0] buffer_roll_rate[63:0];
reg signed [15:0] buffer_pitch_rate[63:0];
reg signed [15:0] buffer_yaw_rate[63:0];
reg signed [21:0] sum_roll = 0;
reg signed [21:0] sum_pitch = 0;
reg signed [21:0] sum_yaw = 0;
reg signed [21:0] sum_roll_rate = 0;
reg signed [21:0] sum_pitch_rate = 0;
reg signed [21:0] sum_yaw_rate = 0;
reg signed [15:0] avg_roll;
reg signed [15:0] avg_pitch;
reg signed [15:0] avg_yaw;
reg signed [15:0] avg_roll_rate;
reg signed [15:0] avg_pitch_rate;

52
reg signed [15:0] avg_yaw_rate;
integer i2;
// initial begin
// for(i2 = 0; i2 < 64;i2 = i2+1) begin
// buffer_roll[i2] = 16'sd0;
// buffer_pitch[i2] = 16'sd0;
// buffer_yaw[i2] = 16'sd0;
// buffer_roll_rate[i2] = 16'sd0;
// buffer_pitch_rate[i2] = 16'sd0;
// buffer_yaw_rate[i2] = 16'sd0;
// end
// end
////////////////////////////////////////////////////////////////////////////////////////////
// State Machine
always @(posedge clock) begin
if(reset) begin
state <= 4'd0;
error_srf05 <= 1'b0;
error_imu <= 1'b0;
motors_start <= 1'b0;
motors_reset <= 1'b1;
throttles <= 32'hFF_FF_FF_FF;
srf05_start <= 1'b0;
srf05_reset <= 1'b1;
offset_distance <= {15{1'b0}};
imu_start <= 1'b0;
imu_reset <= 1'b1;
timer_q <= 3'd0;
sum_dist <= 20'd0;
avg_dist <= 15'd0;
index <= 6'd0;
sum_roll <= 22'sd0;
sum_pitch <= 22'sd0;
sum_yaw <= 22'sd0;
sum_roll_rate <= 22'sd0;
sum_pitch_rate <= 22'sd0;
sum_yaw_rate <= 22'sd0;
avg_roll <= 16'sd0;
avg_pitch <= 16'sd0;
avg_yaw <= 16'sd0;
avg_roll_rate <= 16'sd0;
avg_pitch_rate <= 16'sd0;
avg_yaw_rate <= 16'sd0;
end
else begin
state <= next_state;

53
timer_q <= (state != next_state) ? 4'd0 : timer_d;
//Case Specific Shift Registers
case(state)
RESET:begin
state <= 4'd0;
error_srf05 <= 1'b0;
error_imu <= 1'b0;
motors_start <= 1'b0;
motors_reset <= 1'b1;
throttles <= 32'hFF_FF_FF_FF;
srf05_start <= 1'b0;
srf05_reset <= 1'b1;
offset_distance <= {15{1'b0}};
imu_start <= 1'b0;
imu_reset <= 1'b1;
timer_q <= 3'd0;
end
CALIBRATE: begin
motors_start <= 1'b1;
motors_reset <= 1'b0;
throttles <= (timer_d < 2) ? 32'hFF_FF_FF_FF : 32'd0; //High then low throttle to calibrate
end
CALIBRATE_COMPLETE: begin
motors_start <= 1'b0;
motors_reset <= (timer_d < 3) ? 1'd0 : 1'd1;
throttles <= (timer_d < 3) ? 32'h01_02_03_04 : 32'd0; //Spin Rotors to indicate calibration complete
end
RANGE_SENSOR1: begin
srf05_reset <= 1'b0;
srf05_start <= 1'b1; //start range sensor
end
RANGE_SENSOR2: begin
if(srf05_new_data) begin
sum_dist <= sum_dist + (distance) - (buffer_dist[index]);
buffer_dist[index] <= distance;

54
index <= (index == 6'd31) ? 5'd0 : index + 1'b1; //overflow at 32
end
avg_dist <= sum_dist>>5;
end
RANGE_SENSOR3: begin
offset_distance <= avg_dist; //set initial offset for height
// srf05_reset <= 1'b1; //shut off sensor
srf05_start <= 1'b0;
end
IMU1: begin
imu_reset <= 1'b0;
imu_start <= 1'b1;
end
IMU2: begin
if(imu_new_data) begin
sum_roll <= sum_roll + (cur_roll) - (buffer_roll[index]);
buffer_roll[index] <= cur_roll;
sum_pitch <= sum_pitch + (cur_pitch) - (buffer_pitch[index]);
buffer_pitch[index] <= cur_pitch;
sum_yaw <= sum_yaw + (cur_yaw) - (buffer_yaw[index]);
buffer_yaw[index] <= cur_yaw;
sum_roll_rate <= sum_roll_rate + (cur_roll_rate) - (buffer_roll_rate[index]);
buffer_roll_rate[index] <= cur_roll_rate;
sum_pitch_rate <= sum_pitch_rate + (cur_pitch_rate) - (buffer_pitch_rate[index]);
buffer_pitch_rate[index] <= cur_pitch_rate;
sum_yaw_rate <= sum_yaw_rate + (cur_yaw_rate) - (buffer_yaw_rate[index]);
buffer_yaw_rate[index] <= cur_yaw_rate;
index <= index + 1'b1;
end
avg_roll <= sum_roll/64;
avg_pitch <= sum_pitch/64;
avg_yaw <= sum_yaw/64;

55
avg_roll_rate <= sum_roll_rate/64;
avg_pitch_rate <= sum_pitch_rate/64;
avg_yaw_rate <= sum_yaw_rate/64;
end
IMU3: begin
offset_roll <= avg_roll; //set initial offsets for height
offset_pitch <= avg_pitch; //set initial offset for height
offset_yaw <= avg_yaw; //set initial offset for height
offset_roll_rate <= avg_roll_rate; //set initial offset for height
offset_pitch_rate <= avg_pitch_rate; //set initial offset for height
offset_yaw_rate <= avg_yaw_rate; //set initial offset for height
//Shut off Sensor
srf05_start <= 1'b0;
end
//Spin Rotors to Finish Intialization
END1: begin
motors_start <= 1'b1;
motors_reset <= 1'b0;
throttles <= 32'h01_02_03_04;
end
END2: begin
motors_start <= 1'b0;
motors_reset <= (timer_d < 3) ? 1'd0 : 1'd1;
throttles <= (timer_d < 3) ? 32'h01_02_03_04 : 32'd0;
end
ERROR_SRF05: error_srf05 <= 1'b1;
ERROR_IMU: error_imu <= 1'b1;
endcase
end
end
always @(*) begin
timer_d = timer_q;
//Case Specific Latches
case(state)

56
RESET: next_state = (~start) ? RESET : (calibrate) ? CALIBRATE : RANGE_SENSOR1;
CALIBRATE: begin
timer_d = (en_sec) ? timer_q + 1'b1 : timer_q;
next_state = (timer_q == 4) ? CALIBRATE_COMPLETE : CALIBRATE; //elapsed time = 4 seconds
end
CALIBRATE_COMPLETE: begin
timer_d = (en_sec) ? timer_q + 1'b1 : timer_q;
next_state = (timer_q == 3) ? RANGE_SENSOR1: CALIBRATE_COMPLETE; //elapsed time = 3 seconds
end
//SRF05 Initialize Statements
RANGE_SENSOR1: next_state = RANGE_SENSOR2;
RANGE_SENSOR2: begin
timer_d = (en_sec) ? timer_q + 1'b1 : timer_q;
next_state = (timer_q == 3) ? RANGE_SENSOR3: RANGE_SENSOR2; //elapsed time = 3 seconds
end
RANGE_SENSOR3: next_state = (avg_dist < 100) ? ERROR_SRF05 : IMU1;
//IMU Initialize Statements
IMU1: next_state = IMU2;
IMU2: begin
timer_d = (en_sec) ? timer_q + 1'b1 : timer_q;
next_state = (timer_q == 3) ? IMU3: IMU2; //elapsed time = 3 seconds
end
//IF Roll is especially erroneous, report an error
IMU3: next_state = ((avg_roll > 15'sd4500 && avg_roll < 15'sd13500) || (avg_roll < -15'sd4500 && avg_roll > -15'sd13500)) ?
ERROR_IMU : END1;
//End spin props to signal success
END1: next_state = END2;
END2: begin
timer_d = (en_sec) ? timer_q + 1'b1 : timer_q;
next_state = (timer_q == 3) ? DONE: END2; //elapsed time = 3 seconds
end
ERROR_SRF05: next_state = DONE;
ERROR_IMU: next_state = DONE;
DONE: next_state = DONE;
default: next_state = RESET;
endcase
end