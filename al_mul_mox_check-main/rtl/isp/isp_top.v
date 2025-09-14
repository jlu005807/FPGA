module isp_top 
(
    input  wire                         sys_clk                    ,
    input  wire                         rst_n                      ,
    input  wire                         pre_wr_en                  ,
    input  wire        [  15:0]         isp_data_in                ,
    input  wire        [   7:0]         last_pic                   ,
    input  wire                         pre_vsync                  ,
    input  wire                         pre_href                   ,

    output wire                         isp_vsync                  ,
    output wire                         isp_href                   ,
    output wire                         isp_1bit_out               ,
    output wire                         isp_wr_en                  ,
    output wire        [  15:0]         isp_data_out               ,
    output wire        [   7:0]         img_Y                      ,
    output wire                         ycbcr_wr_en                 
);
    parameter                           DIFF_THR = 'd50            ;
(*keep = 1*)wire                        diff_1bit                  ;
(*keep = 1*)wire                        diff_wr_en                 ;
(*keep = 1*)wire                        erosion_wr_en1             ;
(*keep = 1*)wire                        erosion_1bit_out1          ;
(*keep = 1*)wire                        yuv_href                   ;
(*keep = 1*)wire                        yuv_vsync                  ;
(*keep = 1*)wire                        diff_href                  ;
(*keep = 1*)wire                        diff_vsync                 ;
(*keep = 1*)wire                        erosion_href1              ;
(*keep = 1*)wire                        erosion_vsync1             ;
(*keep = 1*)wire                        erosion_1bit_out2          ;
(*keep = 1*)wire                        erosion_wr_en2             ;
(*keep = 1*)wire                        erosion_vsync2             ;
(*keep = 1*)wire                        erosion_href2              ;
(*keep = 1*)wire       [   7:0]         img_Y_r                    ;
(*keep = 1*)wire                        median_hs                  ;
(*keep = 1*)wire                        median_vs                  ;
(*keep = 1*)wire                        median_wr_En               ;
wire                                    dilation_hs                ;
wire                                    dilation_vs                ;
wire                                    dilation_wr_en             ;
wire                                    dilation_1bit              ;
rgb_ycbcr u_rgb_ycbcr(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .pre_wr_en                         (pre_wr_en                 ),
    .ov5640_data                       (isp_data_in               ),
    .pre_href                          (pre_href                  ),
    .pre_vsync                         (pre_vsync                 ),
    .wr_en_dly                         (ycbcr_wr_en               ),
    .yuv_href                          (yuv_href                  ),
    .yuv_vsync                         (yuv_vsync                 ),
    .rgb565_data                       (                          ),
    .img_y                             (img_Y_r                   ),
    .img_cb                            (                          ),
    .img_cr                            (                          ) 
);
VIP_Gray_Median_Filter u_VIP_Gray_Median_Filter(
    .clk                               (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .pe_frame_vsync                    (yuv_vsync                 ),
    .pe_frame_href                     (yuv_href                  ),
    .pe_frame_clken                    (ycbcr_wr_en               ),
    .pe_img_Y                          (img_Y_r                   ),
    .pos_frame_vsync                   (median_vs                 ),
    .pos_frame_href                    (median_hs                 ),
    .pos_frame_clken                   (median_wr_En              ),
    .pos_img_Y                         (img_Y                     ) 
);


 diff_pic
#(
    .DIFF_THR                          (DIFF_THR                  ) 
)
 u_diff_pic(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .pre_wr_en                         (ycbcr_wr_en                  ),
    .pre_href                          (yuv_href                     ),
    .pre_vsync                         (yuv_vsync                     ),

    .diff_vsync                        (diff_vsync                ),
    .diff_href                         (diff_href                 ),
    .new_pic                           (img_Y               ),
    .last_pic                          (last_pic                  ),
    .diff_1bit_out                     (diff_1bit                 ),
    .diff_wr_en                        (diff_wr_en                ),
    .diff_rgb_565                      (                          ) 
);
isp_1bit_erosion u_isp_1bit_erosion1(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .wr_en                             (diff_wr_en                ),
    .img_1bit_in                       (diff_1bit                 ),
    .pre_href                          (diff_href                 ),
    .pre_vsync                         (diff_vsync                ),
    
    .erosion_href                      (erosion_href1             ),
    .erosion_vsync                     (erosion_vsync1            ),
    .erosion_wr_en                     (erosion_wr_en1            ),
    .img_1bit_out                      (erosion_1bit_out1         ),
    .erosion_rgb565                    (                          ) 
);
isp_1bit_erosion u_isp_1bit_erosion2(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .wr_en                             (erosion_wr_en1            ),
    .img_1bit_in                       (erosion_1bit_out1         ),
    .pre_href                          (erosion_href1             ),
    .pre_vsync                         (erosion_vsync1            ),
    
    .erosion_href                      (erosion_href2             ),
    .erosion_vsync                     (erosion_vsync2            ),
    .erosion_wr_en                     (erosion_wr_en2            ),
    .img_1bit_out                      (erosion_1bit_out2         ),
    .erosion_rgb565                    (                          ) 
);

isp_1bit_dilation u_isp_1bit_dilation(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .wr_en                             (erosion_wr_en2            ),
    .img_1bit_in                       (erosion_1bit_out2         ),
    .pre_href                          (erosion_href2             ),
    .pre_vsync                         (erosion_vsync2            ),
    
    .dilation_href                     (dilation_hs               ),
    .dilation_vsync                    (dilation_vs               ),
    .dilation_wr_en                    (dilation_wr_en            ),
    .img_1bit_out                      (dilation_1bit             ),
    .dilation_data                     (                          ) 
);
isp_1bit_dilation u_isp_1bit_dilation1(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (rst_n                     ),
    .wr_en                             (dilation_wr_en            ),
    .img_1bit_in                       (dilation_1bit             ),
    .pre_href                          (dilation_hs               ),
    .pre_vsync                         (dilation_vs               ),

    .dilation_vsync                    (isp_vsync                 ),
    .dilation_href                     (isp_href                  ),
    .dilation_wr_en                    (isp_wr_en                 ),
    .img_1bit_out                      (isp_1bit_out              ),
    .dilation_data                     (isp_data_out              ) 
);

endmodule                                                           //isp_top