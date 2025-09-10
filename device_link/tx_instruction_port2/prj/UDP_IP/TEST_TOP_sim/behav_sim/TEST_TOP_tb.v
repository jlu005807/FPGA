// Verilog testbench created by TD v6.2.168116
// 2025-09-04 10:20:32

`timescale 1ns / 1ps

module TEST_TOP_tb();

reg clk_50;
reg key1;
reg key2;
reg key3;
reg key4;
reg phy1_rgmii_rx_clk;
reg phy1_rgmii_rx_ctl;
reg [3:0] phy1_rgmii_rx_data;
wire [15:0] dled;
wire [3:0] led_data;
wire phy1_rgmii_tx_clk;
wire phy1_rgmii_tx_ctl;
wire [3:0] phy1_rgmii_tx_data;

//Clock process
parameter PERIOD = 20;
always #(PERIOD/2) clk_50 = ~clk_50;

glbl glbl();

//Unit Instantiate
TEST_TOP u_dut(
	.clk_50(clk_50),
	.key1(key1),
	.key2(key2),
	.key3(key3),
	.key4(key4),
	.phy1_rgmii_rx_clk(phy1_rgmii_rx_clk),
	.phy1_rgmii_rx_ctl(phy1_rgmii_rx_ctl),
	.phy1_rgmii_rx_data(phy1_rgmii_rx_data),
	.dled(dled),
	.led_data(led_data),
	.phy1_rgmii_tx_clk(phy1_rgmii_tx_clk),
	.phy1_rgmii_tx_ctl(phy1_rgmii_tx_ctl),
	.phy1_rgmii_tx_data(phy1_rgmii_tx_data)
);

//Stimulus process
initial begin
//To be inserted
clk_50 = 0;
key1 = 0;
key2 = 1;
key3 = 1;
key4 = 1;
#20
key1 = 1;
#10
key3 = 0;
#1000
key3 = 1;
#10
key4 = 0;
end

endmodule