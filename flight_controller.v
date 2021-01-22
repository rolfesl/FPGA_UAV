`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Flight Control Module Major FSM
//
//////////////////////////////////////////////////////////////////////////////////
module flight_controller #(parameter CALIBRATE_ESC = 1'b0)
(
input clock,
input reset,
// output [7:0] led,
// input fly, //whether should go to fly mode
// input idle, //wheter should go back to IDLE
//JB IMU interface
output imu_start, //start imu signal
output imu_reset, //reset imu signal
input imu_new_data, //new data available
input signed [15:0] roll,
input signed [15:0] pitch,
input signed [15:0] yaw,
input signed [15:0] roll_rate,
input signed [15:0] pitch_rate,
input signed [15:0] yaw_rate,
// //Arithmetic Inputs
Gregory Kravit APPENDIX B: Verilog
30
// input signed [15:0] desired_roll,
// input signed [15:0] desired_pitch,
// input signed [15:0] desired_yaw,
// input signed [15:0] desired_roll_rate,
// input signed [15:0] desired_pitch_rate,
// input signed [15:0] desired_yaw_rate,
//SRF05 interface
output srf05_start, //start height sensor
output srf05_reset, //reset height sensor
input srf05_new_data, //new data available
input [14:0] distance,
//Motor Controller interface
output motors_start,
output motors_idle,
output motors_reset,
output [7:0] throttle1,
output [7:0] throttle2,
output [7:0] throttle3,
output [7:0] throttle4
);
///////////////////////////////////////////////////////////////////////////////////////////////////
// 1 Second Divider
wire reset_div1, en_sec;
divider_sec #(.CLK_FRQ_MHZ(50)) timer_sec(.clock(clock),.reset(reset_div1),.en_sec(en_sec));
Gregory Kravit APPENDIX B: Verilog
31
///////////////////////////////////////////////////////////////////////////////////////////////////
/// Initialization Components
wire signed [15:0] init_roll, init_pitch, init_yaw, init_P, init_Q, init_R;
wire [14:0] init_distance;
reg init_reset, init_start;
wire init_finished;
wire init_reset_div1;
wire error_srf05, error_imu;
wire calibrate;
assign calibrate = CALIBRATE_ESC;
wire [31:0] init_throttles;
wire init_imu_start, init_imu_reset;
wire init_srf_start, init_srf_reset;
wire init_motors_start, init_motors_reset;
//Initialization Module
flight_control_initialize init(
.clock(clock), //clock
.reset(init_reset), //reset initialize
.start(init_start), //start initialization
.done(init_finished), //indicates initialization is done
.error_srf05(error_srf05),
.error_imu(error_imu),
.reset_1sec(init_reset_div1), //reset 1 sec divider
Gregory Kravit APPENDIX B: Verilog
32
.en_sec(en_sec), //divider signal from 1 second divider
.calibrate(calibrate), //if high, calibrate motors
.throttles(init_throttles), //throttle settings for motors
.motors_start(init_motors_start), //start motor controller
.motors_reset(init_motors_reset), //reset motor controller
.srf05_start(init_srf_start), //start height sensor
.srf05_reset(init_srf_reset), //reset height sensor
.srf05_new_data(srf05_new_data),
.distance(distance), //height reading from sensor (in microseconds)
.offset_distance(init_distance), //offset initial height reading (in microseconds)
.imu_start(init_imu_start), //start imu signal
.imu_reset(init_imu_reset), //reset imu signal
.imu_new_data, //new data available
.cur_roll(roll), //roll angle: sensor reading from imu
.cur_pitch(pitch), //pitch angle: sensor reading from imu
.cur_yaw(yaw), //yaw angle: sensor reading from imu
.cur_roll_rate(roll_rate), //roll rate: sensor reading from imu
.cur_pitch_rate(pitch_rate), //pitch rate: sensor reading from imu
Gregory Kravit APPENDIX B: Verilog
33
.cur_yaw_rate(yaw_rate), //yaw rate: sensor reading from imu
.offset_roll(init_roll), //roll angle: offset for control arithmetic
.offset_pitch(init_pitch), //pitch angle: offset for control arithmetic
.offset_yaw(init_yaw), //yaw angle: offset for control arithmetic
.offset_roll_rate(init_P), //roll rate: offset for control arithmetic
.offset_pitch_rate(init_Q), //pitch rate: offset for control arithmetic
.offset_yaw_rate(init_R) //yaw rate: offset for control arithmetic
);