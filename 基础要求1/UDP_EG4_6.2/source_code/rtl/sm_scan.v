`timescale 1ns / 1ps
// sm_scan.v
//********************************************************************** 
module sm_scan(
           input wire clk,
           input                                 app_rx_data_valid       ,
           input                 [   7:   0]     app_rx_data             ,
           input  wire           [  15:   0]     app_rx_data_length      ,
           input                                 udp_rx_clk              ,
           input        reset,   // active low
           output reg [7:0] dataout,
           output reg [7:0] en
       );

reg [15:0] cnt_scan;    // scan frequency divider
reg [3:0]  dataout_buf; // digit to display (0..F)

// receive buffer: store eight 4-bit nibbles (digits 0..7)
reg [63:0] digits_n; // {d7,d6,...,d0}, each 4 bits, d7 is first received byte

// counter: asynchronous active-low reset
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        cnt_scan <= 16'b0;
    end else begin
        cnt_scan <= cnt_scan + 16'b1;
    end
end

reg [15:0] cnt;
always @(posedge udp_rx_clk or negedge reset)
begin
    if(!reset)  begin
        cnt   <=16'b0;
    end
    else if (app_rx_data_valid & cnt<(app_rx_data_length-1))begin
        cnt<=cnt+1;
    end

    else if (app_rx_data_valid & cnt==(app_rx_data_length-1))
        cnt<=16'b0;

    else
        cnt<=cnt;
end

always @(posedge udp_rx_clk or negedge reset)
begin
    if(!reset)
        digits_n<=64'b0;
    else if (app_rx_data_valid)
    case (cnt)
        0:digits_n[63:56]<=app_rx_data;
        1:digits_n[55:48]<=app_rx_data;
        2:digits_n[47:40]<=app_rx_data;
        3:digits_n[39:32]<=app_rx_data;
        4:digits_n[31:24]<=app_rx_data;
        5:digits_n[23:16]<=app_rx_data;
        6:digits_n[15:8] <=app_rx_data;
        7:digits_n[7:0]  <=app_rx_data;
    endcase

    else
        digits_n <=digits_n;
end

// drive digit enable and select which digit to display
// use cnt_scan[15:13] to create 8 states (one per digit)
always @( cnt_scan) begin
    case (cnt_scan[15:13])
        3'b000: begin en = 8'b1111_1110; end
        3'b001: begin en = 8'b1111_1101; end
        3'b010: begin en = 8'b1111_1011; end
        3'b011: begin en = 8'b1111_0111; end
        3'b100: begin en = 8'b1110_1111; end
        3'b101: begin en = 8'b1101_1111; end
        3'b110: begin en = 8'b1011_1111; end
        3'b111: begin en = 8'b0111_1111; end
        default: begin en = 8'b1111_1111; end
    endcase
end

always @(en) begin
    case(en)
        8'b1111_1110: dataout_buf = digits_n[35:32];
        8'b1111_1101: dataout_buf = digits_n[39:36];
        8'b1111_1011: dataout_buf = digits_n[43:40];
        8'b1111_0111: dataout_buf = digits_n[47:44];
        8'b1110_1111: dataout_buf = digits_n[51:48];
        8'b1101_1111: dataout_buf = digits_n[55:52];
        8'b1011_1111: dataout_buf = digits_n[59:56];
        8'b0111_1111: dataout_buf = digits_n[63:60];
        default:      dataout_buf = 4'd0;
    endcase
end

// decode 4-bit digit (0..9) to 7-seg (active low: 0 lights segment)
// segments order: {a,b,c,d,e,f,g}
always @(dataout_buf) begin
    case (dataout_buf)
        4'b0000: dataout <= 8'b1_1000_000; // 7'b0111_111;
        4'b0001: dataout <= 8'b1_1111_001; // 7'b0000_110;
        4'b0010: dataout <= 8'b1_0100_100; // 7'b1011_011;
        4'b0011: dataout <= 8'b1_0110_000; // 7'b1001_111;
        4'b0100: dataout <= 8'b1_0011_001; // 7'b1100_110;
        4'b0101: dataout <= 8'b1_0010_010; // 7'b1101_101;
        4'b0110: dataout <= 8'b1_0000_010; // 7'b1111_101;
        4'b0111: dataout <= 8'b1_1111_000; // 7'b0000_111;
        4'b1000: dataout <= 8'b1_0000_000; // 7'b1111_111;
        4'b1001: dataout <= 8'b1_0010_000; // 7'b1101_111;
        4'b1010: dataout <= 8'b1_0001_000; // 7'b1110_111;
        4'b1011: dataout <= 8'b1_0000_011; // 7'b1111_100;
        4'b1100: dataout <= 8'b1_1000_110; // 7'b0111_001;
        4'b1101: dataout <= 8'b1_0100_001; // 7'b1011_110;
        4'b1110: dataout <= 8'b1_0000_110; // 7'b1111_001;
        4'b1111: dataout <= 8'b1_0001_110; // 7'b1110_001;
        default: dataout <= 8'b1_1000_000; // 7'b0111_111;
    endcase
end

endmodule
