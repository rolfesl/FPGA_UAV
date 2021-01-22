`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:
//
// Create Date: 17:06:44 11/18/2014
// Design Name: Digital Controller for VTOL UAV
// Module Name: pwm
// Project Name:
// Target Devices: Mojov V3 Spartan 6 xclx9
// Tool versions:
// Description: Sends a PWM pulse up to the compare value on a 400 hz refresh
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Based off code examples from embbededmicro.com/tutorials/mojo/pulse-width-modulation
//
//////////////////////////////////////////////////////////////////////////////////
module pwm #(parameter CTR_LEN = 12,

62
parameter REFRESH_RATE_US = 12'd2499) //400 hz = 2500 us period
(
input clock, //clock 50 Mhz
input reset, //reset wire
input [CTR_LEN-1:0] compare, //compare value in microseconds
output pwm //pwm signal out
);
wire one_us;
divider_1us one_us_div(.clock(clock),.reset(reset),.one_us_enable(one_us));
reg pwm_d, pwm_q; //pulse out registers
reg [CTR_LEN-1:0] ctr_d, ctr_q; //counters for pulse
assign pwm = pwm_q & ~reset;
always @(*) begin
ctr_d = (one_us) ? ctr_q + 1'b1 : ctr_q; //if one ms passed, increment q register
pwm_d = (compare > ctr_q) ? 1'b1 : 1'b0; //set pulse high
end
always @(posedge clock) begin
if(reset) ctr_q <= 1'b0;
else ctr_q <= (ctr_d == REFRESH_RATE_US) ? 1'b0 : ctr_d;
//if exceed refresh rate, return to 0. Otherwise except register value.

63
//shift register value
pwm_q <= pwm_d;
end
endmodule
8.7 THROTTLE2PWM.V
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 18:01:43 11/18/2014
// Design Name:
// Module Name: throttle2pwm
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module throttle2pwm #(parameter PWM_LEN = 12)
(

64
input clock,
input reset,
input idle,
input [7:0] throttle_setting,
output [11:0] pwm_signal_time
);
reg [11:0] signal_time;
assign pwm_signal_time = (idle || reset) ? 12'd900 : signal_time;
always @(posedge clock) begin
case(throttle_setting)
8'd0: signal_time = 12'd1064;
8'd1: signal_time = 12'd1067;
8'd2: signal_time = 12'd1070;
8'd3: signal_time = 12'd1073;
8'd4: signal_time = 12'd1077;
8'd5: signal_time = 12'd1080;
8'd6: signal_time = 12'd1083;
8'd7: signal_time = 12'd1086;
8'd8: signal_time = 12'd1089;
8'd9: signal_time = 12'd1092;
8'd10: signal_time = 12'd1095;
8'd11: signal_time = 12'd1099;
8'd12: signal_time = 12'd1102;
8'd13: signal_time = 12'd1105;
8'd14: signal_time = 12'd1108;
8'd15: signal_time = 12'd1111;
8'd16: signal_time = 12'd1114;

65
8'd17: signal_time = 12'd1117;
8'd18: signal_time = 12'd1120;
8'd19: signal_time = 12'd1124;
8'd20: signal_time = 12'd1127;
8'd21: signal_time = 12'd1130;
8'd22: signal_time = 12'd1133;
8'd23: signal_time = 12'd1136;
8'd24: signal_time = 12'd1139;
8'd25: signal_time = 12'd1142;
8'd26: signal_time = 12'd1146;
8'd27: signal_time = 12'd1149;
8'd28: signal_time = 12'd1152;
8'd29: signal_time = 12'd1155;
8'd30: signal_time = 12'd1158;
8'd31: signal_time = 12'd1161;
8'd32: signal_time = 12'd1164;
8'd33: signal_time = 12'd1168;
8'd34: signal_time = 12'd1171;
8'd35: signal_time = 12'd1174;
8'd36: signal_time = 12'd1177;
8'd37: signal_time = 12'd1180;
8'd38: signal_time = 12'd1183;
8'd39: signal_time = 12'd1186;
8'd40: signal_time = 12'd1189;
8'd41: signal_time = 12'd1193;
8'd42: signal_time = 12'd1196;
8'd43: signal_time = 12'd1199;
8'd44: signal_time = 12'd1202;
8'd45: signal_time = 12'd1205;

66
8'd46: signal_time = 12'd1208;
8'd47: signal_time = 12'd1211;
8'd48: signal_time = 12'd1215;
8'd49: signal_time = 12'd1218;
8'd50: signal_time = 12'd1221;
8'd51: signal_time = 12'd1224;
8'd52: signal_time = 12'd1227;
8'd53: signal_time = 12'd1230;
8'd54: signal_time = 12'd1233;
8'd55: signal_time = 12'd1237;
8'd56: signal_time = 12'd1240;
8'd57: signal_time = 12'd1243;
8'd58: signal_time = 12'd1246;
8'd59: signal_time = 12'd1249;
8'd60: signal_time = 12'd1252;
8'd61: signal_time = 12'd1255;
8'd62: signal_time = 12'd1259;
8'd63: signal_time = 12'd1262;
8'd64: signal_time = 12'd1265;
8'd65: signal_time = 12'd1268;
8'd66: signal_time = 12'd1271;
8'd67: signal_time = 12'd1274;
8'd68: signal_time = 12'd1277;
8'd69: signal_time = 12'd1280;
8'd70: signal_time = 12'd1284;
8'd71: signal_time = 12'd1287;
8'd72: signal_time = 12'd1290;
8'd73: signal_time = 12'd1293;
8'd74: signal_time = 12'd1296;

67
8'd75: signal_time = 12'd1299;
8'd76: signal_time = 12'd1302;
8'd77: signal_time = 12'd1306;
8'd78: signal_time = 12'd1309;
8'd79: signal_time = 12'd1312;
8'd80: signal_time = 12'd1315;
8'd81: signal_time = 12'd1318;
8'd82: signal_time = 12'd1321;
8'd83: signal_time = 12'd1324;
8'd84: signal_time = 12'd1328;
8'd85: signal_time = 12'd1331;
8'd86: signal_time = 12'd1334;
8'd87: signal_time = 12'd1337;
8'd88: signal_time = 12'd1340;
8'd89: signal_time = 12'd1343;
8'd90: signal_time = 12'd1346;
8'd91: signal_time = 12'd1349;
8'd92: signal_time = 12'd1353;
8'd93: signal_time = 12'd1356;
8'd94: signal_time = 12'd1359;
8'd95: signal_time = 12'd1362;
8'd96: signal_time = 12'd1365;
8'd97: signal_time = 12'd1368;
8'd98: signal_time = 12'd1371;
8'd99: signal_time = 12'd1375;
8'd100: signal_time = 12'd1378;
8'd101: signal_time = 12'd1381;
8'd102: signal_time = 12'd1384;
8'd103: signal_time = 12'd1387;

68
8'd104: signal_time = 12'd1390;
8'd105: signal_time = 12'd1393;
8'd106: signal_time = 12'd1397;
8'd107: signal_time = 12'd1400;
8'd108: signal_time = 12'd1403;
8'd109: signal_time = 12'd1406;
8'd110: signal_time = 12'd1409;
8'd111: signal_time = 12'd1412;
8'd112: signal_time = 12'd1415;
8'd113: signal_time = 12'd1419;
8'd114: signal_time = 12'd1422;
8'd115: signal_time = 12'd1425;
8'd116: signal_time = 12'd1428;
8'd117: signal_time = 12'd1431;
8'd118: signal_time = 12'd1434;
8'd119: signal_time = 12'd1437;
8'd120: signal_time = 12'd1440;
8'd121: signal_time = 12'd1444;
8'd122: signal_time = 12'd1447;
8'd123: signal_time = 12'd1450;
8'd124: signal_time = 12'd1453;
8'd125: signal_time = 12'd1456;
8'd126: signal_time = 12'd1459;
8'd127: signal_time = 12'd1462;
8'd128: signal_time = 12'd1466;
8'd129: signal_time = 12'd1469;
8'd130: signal_time = 12'd1472;
8'd131: signal_time = 12'd1475;
8'd132: signal_time = 12'd1478;

69
8'd133: signal_time = 12'd1481;
8'd134: signal_time = 12'd1484;
8'd135: signal_time = 12'd1488;
8'd136: signal_time = 12'd1491;
8'd137: signal_time = 12'd1494;
8'd138: signal_time = 12'd1497;
8'd139: signal_time = 12'd1500;
8'd140: signal_time = 12'd1503;
8'd141: signal_time = 12'd1506;
8'd142: signal_time = 12'd1509;
8'd143: signal_time = 12'd1513;
8'd144: signal_time = 12'd1516;
8'd145: signal_time = 12'd1519;
8'd146: signal_time = 12'd1522;
8'd147: signal_time = 12'd1525;
8'd148: signal_time = 12'd1528;
8'd149: signal_time = 12'd1531;
8'd150: signal_time = 12'd1535;
8'd151: signal_time = 12'd1538;
8'd152: signal_time = 12'd1541;
8'd153: signal_time = 12'd1544;
8'd154: signal_time = 12'd1547;
8'd155: signal_time = 12'd1550;
8'd156: signal_time = 12'd1553;
8'd157: signal_time = 12'd1557;
8'd158: signal_time = 12'd1560;
8'd159: signal_time = 12'd1563;
8'd160: signal_time = 12'd1566;
8'd161: signal_time = 12'd1569;

70
8'd162: signal_time = 12'd1572;
8'd163: signal_time = 12'd1575;
8'd164: signal_time = 12'd1579;
8'd165: signal_time = 12'd1582;
8'd166: signal_time = 12'd1585;
8'd167: signal_time = 12'd1588;
8'd168: signal_time = 12'd1591;
8'd169: signal_time = 12'd1594;
8'd170: signal_time = 12'd1597;
8'd171: signal_time = 12'd1600;
8'd172: signal_time = 12'd1604;
8'd173: signal_time = 12'd1607;
8'd174: signal_time = 12'd1610;
8'd175: signal_time = 12'd1613;
8'd176: signal_time = 12'd1616;
8'd177: signal_time = 12'd1619;
8'd178: signal_time = 12'd1622;
8'd179: signal_time = 12'd1626;
8'd180: signal_time = 12'd1629;
8'd181: signal_time = 12'd1632;
8'd182: signal_time = 12'd1635;
8'd183: signal_time = 12'd1638;
8'd184: signal_time = 12'd1641;
8'd185: signal_time = 12'd1644;
8'd186: signal_time = 12'd1648;
8'd187: signal_time = 12'd1651;
8'd188: signal_time = 12'd1654;
8'd189: signal_time = 12'd1657;
8'd190: signal_time = 12'd1660;

71
8'd191: signal_time = 12'd1663;
8'd192: signal_time = 12'd1666;
8'd193: signal_time = 12'd1669;
8'd194: signal_time = 12'd1673;
8'd195: signal_time = 12'd1676;
8'd196: signal_time = 12'd1679;
8'd197: signal_time = 12'd1682;
8'd198: signal_time = 12'd1685;
8'd199: signal_time = 12'd1688;
8'd200: signal_time = 12'd1691;
8'd201: signal_time = 12'd1695;
8'd202: signal_time = 12'd1698;
8'd203: signal_time = 12'd1701;
8'd204: signal_time = 12'd1704;
8'd205: signal_time = 12'd1707;
8'd206: signal_time = 12'd1710;
8'd207: signal_time = 12'd1713;
8'd208: signal_time = 12'd1717;
8'd209: signal_time = 12'd1720;
8'd210: signal_time = 12'd1723;
8'd211: signal_time = 12'd1726;
8'd212: signal_time = 12'd1729;
8'd213: signal_time = 12'd1732;
8'd214: signal_time = 12'd1735;
8'd215: signal_time = 12'd1739;
8'd216: signal_time = 12'd1742;
8'd217: signal_time = 12'd1745;
8'd218: signal_time = 12'd1748;
8'd219: signal_time = 12'd1751;

72
8'd220: signal_time = 12'd1754;
8'd221: signal_time = 12'd1757;
8'd222: signal_time = 12'd1760;
8'd223: signal_time = 12'd1764;
8'd224: signal_time = 12'd1767;
8'd225: signal_time = 12'd1770;
8'd226: signal_time = 12'd1773;
8'd227: signal_time = 12'd1776;
8'd228: signal_time = 12'd1779;
8'd229: signal_time = 12'd1782;
8'd230: signal_time = 12'd1786;
8'd231: signal_time = 12'd1789;
8'd232: signal_time = 12'd1792;
8'd233: signal_time = 12'd1795;
8'd234: signal_time = 12'd1798;
8'd235: signal_time = 12'd1801;
8'd236: signal_time = 12'd1804;
8'd237: signal_time = 12'd1808;
8'd238: signal_time = 12'd1811;
8'd239: signal_time = 12'd1814;
8'd240: signal_time = 12'd1817;
8'd241: signal_time = 12'd1820;
8'd242: signal_time = 12'd1823;
8'd243: signal_time = 12'd1826;
8'd244: signal_time = 12'd1829;
8'd245: signal_time = 12'd1833;
8'd246: signal_time = 12'd1836;
8'd247: signal_time = 12'd1839;
8'd248: signal_time = 12'd1842;

73
8'd249: signal_time = 12'd1845;
8'd250: signal_time = 12'd1848;
8'd251: signal_time = 12'd1851;
8'd252: signal_time = 12'd1855;
8'd253: signal_time = 12'd1858;
8'd254: signal_time = 12'd1861;
8'd255: signal_time = 12'd1864;
endcase
end
endmodule