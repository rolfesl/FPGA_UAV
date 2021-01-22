`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Motor Control Module
//
// Acts as a black box to flight control module
// -- Two States On or Off
// -- Flight Control Module Must Tell it To Stop, or go IDLE
//////////////////////////////////////////////////////////////////////////////////
module motor_controller(
input clock,
input start,
input idle,
input reset,
input [7:0] throttle1,
input [7:0] throttle2,
input [7:0] throttle3,
input [7:0] throttle4,
output [3:0] motor_signals
);
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Motor Controller State Machine
localparam IDLE = 1'b0;
localparam ON = 1'b1;
reg state, next_state;
wire pwm_reset;
reg pwm_on_q, pwm_on_d;
assign pwm_reset = ~pwm_on_q;
always @(posedge clock) begin
if(reset) begin
Gregory Kravit APPENDIX B: Verilog
59
state <= IDLE;
pwm_on_q <= 1'b0;
end
else begin
state <= next_state;
pwm_on_q <= pwm_on_d;
end
end
always @(*) begin
case(state)
IDLE: begin
next_state = (start) ? ON : IDLE;
pwm_on_d = 1'b0;
end
ON: begin
next_state = ON;
pwm_on_d = 1'b1;
end
endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Throttle 2 PWM Lookup Tables
//
wire [11:0] pwm_signal[3:0];
wire [47:0] compare;
throttle2pwm throttleLUT1(
.clock(clock),
.reset(pwm_reset),
.idle(idle),
.throttle_setting(throttle1),
.pwm_signal_time(compare[47:36])
);
throttle2pwm throttleLUT2(
.clock(clock),
.reset(pwm_reset),
.idle(idle),
.throttle_setting(throttle2),
.pwm_signal_time(compare[35:24])
);
throttle2pwm throttleLUT3(
.clock(clock),
.reset(pwm_reset),
Gregory Kravit APPENDIX B: Verilog
60
.idle(idle),
.throttle_setting(throttle3),
.pwm_signal_time(compare[23:12])
);
throttle2pwm throttleLUT4(
.clock(clock),
.reset(pwm_reset),
.idle(idle),
.throttle_setting(throttle4),
.pwm_signal_time(compare[11:0])
);
///////////////////////////////////////////////////////////////////////////////////////////////////////
// PWM Modules
///////////////////////////////////////////////////////////////////////////////////////////////////////
wire pwm1,pwm2,pwm3,pwm4;
assign motor_signals = {pwm1,pwm2,pwm3,pwm4}; //output of motor controller
pwm motor1 //400 hz = 2500 us period
(
.clock(clock), //clock 50 Mhz
.reset(pwm_reset), //reset wire
.compare(compare[47:36]), //compare value in microseconds
.pwm(pwm1) //pwm signal out
);
pwm motor2 //400 hz = 2500 us period
(
.clock(clock), //clock 50 Mhz
.reset(pwm_reset), //reset wire
.compare(compare[35:24]), //compare value in microseconds
.pwm(pwm2) //pwm signal out
);
pwm motor3 //400 hz = 2500 us period
(
.clock(clock), //clock 50 Mhz
.reset(pwm_reset), //reset wire
.compare(compare[23:12]), //compare value in microseconds
.pwm(pwm3) //pwm signal out
);
Gregory Kravit APPENDIX B: Verilog
61
pwm motor4 //400 hz = 2500 us period
(
.clock(clock), //clock 50 Mhz
.reset(pwm_reset), //reset wire
.compare(compare[11:0]), //compare value in microseconds
.pwm(pwm4) //pwm signal out
);
endmodule