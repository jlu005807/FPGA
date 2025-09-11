`define UDP_LOOP_BACK
`define DEBUG_UDP
module TEST_TOP(
     input               key1, //这个也是复位的，复位led的，但其实我不知道有啥用
     input               key2,//这个是复位的
     input               clk_50, 
        
     input               phy1_rgmii_rx_clk,
     input               phy1_rgmii_rx_ctl,
     input [3:0]         phy1_rgmii_rx_data,
                                
     output wire         phy1_rgmii_tx_clk,
     output wire         phy1_rgmii_tx_ctl,
     output wire [3:0]   phy1_rgmii_tx_data , 
     
     output  wire[3:0] led_data,
     output  wire[15:0] dled  
 );
 wire udp_clk;
 wire tx_clk;
 wire rx_clk;
 wire reset;
 reg [7:0] my_tx_data;
 wire my_flagg;
 
 wire[15:0] rx_data_length;
 wire[7:0]  rx_data;
 wire rx_data_valid;

 led my_led(
    .app_rx_data_valid(rx_data_valid)       ,
    .app_rx_data(rx_data)             ,
    .app_rx_data_length(rx_data_length)      ,
    .udp_rx_clk(rx_clk)             ,
    .reset(key1)                   ,
    .led_data_1(led_data) ,
    .dled(dled)   
 );
 
 //这个就是UDP收发IP
     UDP_IP my_UDP(
       .key1(key1),//这个不知道是干嘛的，好像是用来debug的
       .key2(key2),//这个是复位的
       .clk_50(clk_50), 
       .reset(reset),
       .udp_clk(udp_clk) ,
        
        .phy1_rgmii_rx_clk(phy1_rgmii_rx_clk),
        .phy1_rgmii_rx_ctl(phy1_rgmii_rx_ctl),
        .phy1_rgmii_rx_data(phy1_rgmii_rx_data),
                                
        .phy1_rgmii_tx_clk(phy1_rgmii_tx_clk),
        .phy1_rgmii_tx_ctl(phy1_rgmii_tx_ctl),
        .phy1_rgmii_tx_data(phy1_rgmii_tx_data),
        
        
    `ifdef DEBUG_UDP
       .debug_out(),
    `endif
    //接收
       .app_rx_clk(rx_clk),//udp_clk
       .app_rx_data_valid(rx_data_valid), 
       .app_rx_data(rx_data),      
       .app_rx_data_length(rx_data_length),
       .app_rx_port_num(),
    //发送      
        .app_tx_clk(tx_clk),//udp_clk
        .user_tx_data(my_tx_data), //发送的数据
        .user_tx_data_valid(my_flagg),
        .user_tx_data_length(10'd1)//字节数
        //input   wire [15:0]  tx_dst_port //这个是目的端口，这个参数在下面的DST_UDP_PORT_NUM中定义了2
     );
    
    
    reg[40:0] my_cnt;
    always@(posedge tx_clk or posedge reset)begin
        if(reset)
            my_cnt <= 0;
        else if(my_cnt < 40'd500_000_00)
            my_cnt <= my_cnt + 1;
        else my_cnt <= 0; 
    end

    
assign my_flagg = (my_cnt == 32'd500_000_00);

reg[5:0] my_index;
always@(posedge tx_clk or posedge reset)begin
    if(reset)
        my_index <= 0;
    else if(my_cnt == 32'd500_000_00)
        my_index <= my_index + 1;
    else if(my_index == 3)
        my_index <= 0;
end


always@(*)begin
    case(my_index)
        0:my_tx_data = 8'hab;
        1:my_tx_data = 8'hcd;
        2:my_tx_data = 8'hef;
        default:my_tx_data = 8'hff;
    endcase
end


endmodule
