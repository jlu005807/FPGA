module ov5640_mov_check (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         cam_pclk                   ,
    input  wire                         cam_vsync                     ,
    input  wire                         cam_href                     ,
    input  wire        [   7:0]         cam_data                   ,
    output  wire                         cam_xclk                   ,

    output wire                         cam_scl                    ,
    inout  wire                         cam_sda                    ,

 //   output wire        [  23:0]         vga_rgb888                 ,
 //   output wire                         vga_hs                     ,
 //   output wire                         vga_vs                     ,
 //   output wire                         vga_clk                    ,
    output wire                         cam_rst_n                  ,
    output wire                         cam_pwdn                   ,
    //hdmi接口                         
	//HDMI
	output wire			HDMI_CLK_P,
	output wire			HDMI_D2_P,
	output wire			HDMI_D1_P,
	output wire			HDMI_D0_P
    
//    output wire                         clk_50m                    
//    output wire        [   3:0]         sel                        ,
//    output wire        [   7:0]         seg_data                   ,

//    output wire                         led_r                      ,
//    output wire                         led_g                      ,
//    output wire                         led_b                      ,
//    output wire        [  15:0]         led                         
);

    parameter                           DIFF_THR = 'D60            ;
    parameter                           CLK_FREQ = 'D40_000_000    ;
    parameter                           MIN_DISC = 'd100           ;
    parameter                           H_PIXEL     =   11'd800    ;//水平方向像素个数,用于设置SDRAM缓存大小
    parameter                           V_PIXEL     =   10'd600    ;//垂直方向像素个数,用于设置SDRAM缓存大小
wire                                    cfg_done                   ;
wire                                    sys_init_done              ;//初始化完成标志，摄像头+sdram
(*keep = 1*)wire       [  15:0]         ov5640_data_out            ;
(*keep = 1*)wire                        ov5640_wr_en               ;

wire                                    clk_100m                   ;
wire                                    clk_100m_shift             ;
(*keep = 1*)wire                        locked                     ;
(*keep = 1*)wire                        locked_cam                     ;
(*keep = 1*)wire                        locked_hdmi                     ;

//wire vga_clk;
wire                                    rst_n = /*locked & sys_rst_n*/locked & locked_hdmi & sys_rst_n ;

wire                                    ycbcr_wr_en                ;
(*keep = 1*)wire       [   7:0]         img_Y                      ;

(*keep = 1*)wire                        data_req                   ;
wire                   [   7:0]         last_pic                   ;
wire                   [   7:0]         new_pic                    ;
(*keep = 1*)wire                        isp_1bit_out               ;
(*keep = 1*)wire                        isp_wr_en                  ;
(*keep = 1*)wire                        isp_href                   ;
(*keep = 1*)wire                        isp_vsync                  ;
wire                   [  15:0]         isp_data_out               ;
(*keep = 1*)wire       [  15:0]         tft_rgb565                 ;
wire                                    ov5640_href_out            ;
wire                                    ov5640_vsync_out           ;
wire                   [  15:0]         boundary_data              ;
wire                                    boundary_wr_en             ;

//*mul_obj_check
wire                                    mul_hs                     ;
wire                                    mul_vs                     ;
wire                                    mul_wr_en                  ;
wire [42:0] pos_data [15:0];
//*fusion
wire                                    fusion_hs                  ;
wire                                    fusion_vs                  ;
wire                                    fusion_wr_en               ;
wire                   [  15:0]         fusion_rgb565              ;
wire                   [  23:0]         fusion_rgb888              ;
wire                   [   7:0]         obj_num                    ;
wire                                    syn_wr_en                  ;
wire                                    syn_hs                     ;
wire                                    syn_vs                     ;
wire [15:0] syn_data ;  
(*keep = 1*)wire [15:0] vga_rgb;
(*keep = 1*)wire [15:0] rd_data;
wire                                    sdram_init_done            ;
assign sys_init_done = cfg_done /* & sdram_init_done */;
assign cam_rst_n = 1'b1;
assign cam_pwdn  = 1'b0;

wire [23:0] vga_rgb888;
wire                         vga_hs                    ;
wire                         vga_vs                     ;
wire                         vga_clk                    ;

//各类时钟
clk_gen u_clk_gen(
    .refclk                            (sys_clk                   ),
    .reset                             (~sys_rst_n                ),
    .extlock                           (locked                    ),
    .clk0_out                          (                          ),
    .clk1_out                          (vga_clk                   ),
    .clk2_out                          (clk_100m                  ),
    .clk3_out                          (clk_100m_shift            ),
    //.clk4_out                          (clk_50m                   ) 
    .clk4_out                          (                   ) 
);
wire hdmi_5x_clk;
 PLL_0 Hdmi_gen(
  .refclk(sys_clk                   ),
  .reset(~sys_rst_n                ),
  .extlock(locked_hdmi                    ),
  .clk0_out(hdmi_5x_clk) 
);
PLL_1 cam_gen(
  .refclk(sys_clk                   ),
  .reset(~sys_rst_n                ),
  .extlock(locked_cam                    ),
  .clk0_out (cam_xclk)
);
//OV5640
ov5640_top
#(
    .CLK_FREQ                          (CLK_FREQ                  ) 
)
u_ov5640_top(
    .sys_rst_n                         (rst_n                     ),
    .sys_clk                           (vga_clk                   ),
    .ov5640_pclk                       (cam_pclk                  ),
    .ov5640_href                       (cam_href                    ),
    .ov5640_data                       (cam_data                  ),
    .sys_init_done                     (sys_init_done             ),

    .ov5640_vsync                      (cam_vsync                    ),
    .ov5640_wr_en                      (ov5640_wr_en              ),
    .ov5640_data_out                   (ov5640_data_out           ),
    .cfg_done                          (cfg_done                  ),
    .cam_hs                            (ov5640_href_out           ),
    .cam_vs                            (ov5640_vsync_out          ),
    .sccb_scl                          (cam_scl                   ),
    .sccb_sda                          (cam_sda                   ) 
);

Sdram_Control_4Port u_Sdram_Control_4Port(
    .CTRL_CLK                          (clk_100m                  ),//System Clock
    .SDRAM_CLK                         (clk_100m_shift            ),//SDRAM Clock
    .RESET_N                           (rst_n                     ),//System Reset

    .WR1_DATA                          ({8'd0,img_Y}              ),//Data input
    .WR1                               (ycbcr_wr_en               ),
    .WR1_ADDR                          (H_PIXEL*V_PIXEL           ),
    .WR1_MAX_ADDR                      (H_PIXEL*V_PIXEL*2         ),
    .WR1_LENGTH                        (10'd256                   ),
    .WR1_LOAD                          (~rst_n                    ),
    .WR1_CLK                           (cam_pclk                  ),
    .WR1_FULL                          (                          ),
    .WR1_USE                           (                          ),

    .WR2_DATA                          (fusion_rgb565   /* isp_data_out */          ),
    .WR2                               (fusion_wr_en    /* isp_wr_en */          ),
    .WR2_ADDR                          (0                         ),
    .WR2_MAX_ADDR                      (H_PIXEL*V_PIXEL           ),
    .WR2_LENGTH                        (10'd256                   ),
    .WR2_LOAD                          (~rst_n                    ),
    .WR2_CLK                           (cam_pclk                  ),
    .WR2_FULL                          (                          ),
    .WR2_USE                           (                          ),

    .RD1_DATA                          (last_pic                  ),
    .RD1                               (ycbcr_wr_en               ),
    .RD1_ADDR                          (H_PIXEL*V_PIXEL           ),
    .RD1_MAX_ADDR                      (H_PIXEL*V_PIXEL*2         ),
    .RD1_LENGTH                        (10'd256                   ),
    .RD1_LOAD                          (~rst_n                    ),
    .RD1_CLK                           (cam_pclk                  ),
    .RD1_EMPTY                         (                          ),
    .RD1_USE                           (                          ),

    .RD2_DATA                          (vga_rgb                   ),
    .RD2                               (data_req                  ),
    .RD2_ADDR                          (0                         ),
    .RD2_MAX_ADDR                      (H_PIXEL*V_PIXEL           ),
    .RD2_LENGTH                        (10'd256                   ),
    .RD2_LOAD                          (~rst_n                    ),
    .RD2_CLK                           (vga_clk                   ),
    .RD2_EMPTY                         (                          ),//Read fifo empty
    .RD2_USE                           (                          ) 
);
//输出处理后的图像和运动检测结果
isp_top
#(
    .DIFF_THR                          (DIFF_THR                  ) 
)
u_isp_top(
    .sys_clk                           (cam_pclk                  ),
    .rst_n                             (rst_n                     ),
    .pre_wr_en                         (ov5640_wr_en              ),
    .isp_data_in                       (ov5640_data_out           ),
    .last_pic                          (last_pic                  ),
    .pre_vsync                         (ov5640_vsync_out          ),
    .pre_href                          (ov5640_href_out           ),

    .isp_vsync                         (isp_vsync                 ),
    .isp_href                          (isp_href                  ),
    .img_Y                             (img_Y                     ),
    .isp_1bit_out                      (isp_1bit_out              ),
    .isp_wr_en                         (isp_wr_en                 ),
    .isp_data_out                      (isp_data_out              ),
    .ycbcr_wr_en                       (ycbcr_wr_en               ) 
); 

cam_syn u_cam_syn(
    .sys_clk                           (cam_pclk                  ),
    .sys_rst_n                         (rst_n                     ),
    .pre_wr_en                         (ov5640_wr_en              ),
    .pre_vs                            (ov5640_vsync_out          ),
    .pre_hs                            (ov5640_href_out           ),
    .cam_data                          (ov5640_data_out           ),
    .syn_wr_en                         (syn_wr_en                 ),
    .syn_hs                            (syn_hs                    ),
    .syn_vs                            (syn_vs                    ),
    .syn_data                          (syn_data                  ) 
);

isp_mul_obj_check
#(
    .H_PIXEL                           (H_PIXEL                   ),
    .V_PIXEL                           (V_PIXEL                   ),
    .MIN_DISC                          (MIN_DISC                  ) 
)
u_isp_mul_obj_check(
    .sys_clk                           (cam_pclk                  ),
    .sys_rst_n                         (rst_n                     ),
    .pre_hs                            (isp_href                  ),
    .pre_vs                            (isp_vsync                 ),
    .pre_wr_en                         (isp_wr_en                 ),
    .pre_1bit                          (isp_1bit_out              ),

    .mul_hs                            (mul_hs                    ),
    .mul_vs                            (mul_vs                    ),
    .mul_wr_en                         (mul_wr_en                 ),
    .pos_data_out                      (pos_data                  ) 
);

boundary_fusion
#(
    .H_PIXEL                           (H_PIXEL                   ),
    .V_PIXEL                           (V_PIXEL                   ) 
)
u_boundary_fusion(
    .sys_clk                           (cam_pclk                  ),
    .sys_rst_n                         (rst_n                     ),
    .pre_wr_en                         (mul_wr_en                 ),
    .pre_hs                            (mul_hs                    ),
    .pre_vs                            (mul_vs                    ),
    .pos_data                          (pos_data                  ),
    .cam_data                          (syn_data                  ),

    .fusion_rgb565                     (fusion_rgb565             ),
    .fusion_rgb888                     (fusion_rgb888             ),
    .fusion_hs                         (fusion_hs                 ),
    .fusion_vs                         (fusion_vs                 ),
    .fusion_wr_en                      (fusion_wr_en              ),
    .fusion_r                          (                          ),
    .fusion_g                          (                          ),
    .fusion_b                          (                          ),
    .obj_num                           (obj_num                   ) 
);
//vga566->vga888
wire vga_de;
vga_ctrl u_vga_ctrl(
    .vga_clk                           (vga_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .pix_data                          (vga_rgb                   ),
    .data_req                          (data_req                  ),
    .vga_hs                            (vga_hs                    ),
    .vga_vs                            (vga_vs                    ),
    .rgb_888                           (vga_rgb888                ),
    .vga_de                            (vga_de) 
);


//seg_4 u_seg4(
//    .clk_24m                           (cam_pclk                  ),
//    .rst_n                             (rst_n                     ),
//    .sm_seg_num                        (obj_num                   ),
//    .sm_seg                            (seg_data                  ),
//    .sm_bit                            (sel                       ) 
//);
//rgb_led u_rgb_led(
//    .clk_24m                           (clk_50m                   ),
//    .led_r                             (led_r                     ),
//    .led_g                             (led_g                     ),
//    .led_b                             (led_b                     ) 
//);
//running_led u_running_led(
 //   .clk_24m                           (clk_50m                   ),
 //   .rst_n                             (rst_n                     ),
 //   .led                               (led                       ) 
//);

    
hdmi_tx #(.FAMILY("EG4"))	//EF2、EF3、EG4、AL3、PH1

 u3_hdmi_tx
	(
		.PXLCLK_I(vga_clk),
		.PXLCLK_5X_I(hdmi_5x_clk),

		.RST_N (rst_n),
		
		//VGA
		.VGA_HS (vga_hs ),
		.VGA_VS (vga_vs ),
		.VGA_DE (vga_de),
		.VGA_RGB(vga_rgb888),

		//HDMI
		.HDMI_CLK_P(HDMI_CLK_P),
		.HDMI_D2_P (HDMI_D2_P ),
		.HDMI_D1_P (HDMI_D1_P ),
		.HDMI_D0_P (HDMI_D0_P )	
		
	);

endmodule                                                           //ov5640_mov_detect