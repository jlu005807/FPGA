module  sdram_top(
    input         sys_clk,           //sdram 控制器参考时钟
    input         clk_out,           //用于输出的相位偏移时钟
    input         sys_rst_n,             //系统复位
    
    //用户写端口         
    input         wr_fifo_wr_clk0,           //写端口FIFO0: 写时钟
    input         wr_fifo_wr_req0,            //写端口FIFO0: 写使能
    input  [15:0] wr_fifo_wr_data0,          //写端口FIFO0: 写数据
    
	input         wr_fifo_wr_clk1,           //写端口FIFO1: 写时钟
	input         wr_fifo_wr_req1,            //写端口FIFO1: 写使能
	input  [15:0] wr_fifo_wr_data1,          //写端口FIFO1: 写数据
    
    input  [20:0] sdram_wr_b_addr,       //写SDRAM的起始地址
    input  [20:0] sdram_wr_e_addr,       //写SDRAM的结束地址
    input  [ 9:0] wr_burst_len,            //写SDRAM时的数据突发长度
    input         wr_rst,           //写端口复位: 复位写地址,清空写FIFO
                                     
    //用户读端口
	input         rd_fifo_rd_clk0,            //读端口FIFO: 读时钟
    input         rd_fifo_rd_req0 ,            //读端口FIFO: 读使能
    output [15:0] rd_fifo_rd_data0,
   
	input         rd_fifo_rd_clk1,            //读端口FIFO: 读时钟
    input         rd_fifo_rd_req1 ,            //读端口FIFO: 读使能
    output [15:0] rd_fifo_rd_data1,
      
    input  [20:0] sdram_rd_b_addr,       //读SDRAM的起始地址
    input  [20:0] sdram_rd_e_addr,       //读SDRAM的结束地址
    input  [ 9:0] rd_burst_len,            //从SDRAM中读数据时的突发长度
    input         rd_rst,   
    //用户控制端口  
    input         read_valid,  //SDRAM 读使能
    input         pingpang_en, //SDRAM 乒乓操作使能
    output        init_end
    );
wire        sdram_clk   ;  
wire        sdram_cke   ;  
wire        sdram_cs_n  ; 
wire        sdram_ras_n ;
wire        sdram_cas_n ;
wire        sdram_we_n  ; 
wire [ 1:0] sdram_ba    ;   
wire [10:0] sdram_addr  ; 
wire [31:0] sdram_dq    ;   
wire [ 1:0] sdram_dqm   ;
//wire define
wire        sdram_wr_req;           //sdram 写请求
wire        sdram_wr_ack;           //sdram 写响应
wire [20:0] sdram_wr_addr;          //sdram 写地址
wire [15:0] sdram_din;              //写入sdram中的数据

wire        sdram_rd_req;           //sdram 读请求
wire        sdram_rd_ack;           //sdram 读响应
wire [20:0] sdram_rd_addr;          //sdram 读地址
wire [15:0] sdram_dout;             //从sdram中读出的数据

//*****************************************************
//**                    main code
//***************************************************** 

assign  sdram_clk = clk_out;                //将相位偏移时钟输出给sdram芯片
assign  sdram_dqm = 2'b00;                  //读写过程中均不屏蔽数据线
            
//SDRAM 读写端口FIFO控制模块
fifo_ctrl u_fifo_ctrl(
      .sys_clk  (sys_clk),   //SDRAM控制器时钟
      .sys_rst_n(sys_rst_n), //系统复位

      //用户写端口                            
      .clk_write0 (wr_fifo_wr_clk0),   //写端口FIFO0: 写时钟
      .wr_req0    (wr_fifo_wr_req0),   //写端口FIFO1: 写请求
      .clk_write1 (wr_fifo_wr_clk1),   //写端口FIFO0: 写时钟
      .wr_req1    (wr_fifo_wr_req1),   //写端口FIFO1: 写请求
      .wr_data_in0(wr_fifo_wr_data0),  //写端口FIFO0: 写数据 
      .wr_data_in1(wr_fifo_wr_data1),  //写端口FIFO1: 写数据 	
      .wr_min_addr(sdram_wr_b_addr),   //写SDRAM的起始地址
      .wr_max_addr(sdram_wr_e_addr),   //写SDRAM的结束地址
      .wr_length  (wr_burst_len),      //写SDRAM时的数据突发长度
      .wr_rst     (wr_rst),            //写端口复位: 复位写地址,清空写FIFO    

      //用户读端口                                              
      .clk_read0(rd_fifo_rd_clk0),  //读端口FIFO0: 读时钟
      .rd_req0  (rd_fifo_rd_req0),  //读端口FIFO: 读请求
      .rd_data0 (rd_fifo_rd_data0),

      .clk_read1(rd_fifo_rd_clk1),  //读端口FIFO0: 读时钟
      .rd_req1  (rd_fifo_rd_req1),  //读端口FIFO: 读请求
      .rd_data1 (rd_fifo_rd_data1),

      .rd_min_addr(sdram_rd_b_addr),  //读SDRAM的起始地址
      .rd_max_addr(sdram_rd_e_addr),  //读SDRAM的结束地址
      .rd_length  (rd_burst_len),     //从SDRAM中读数据时的突发长度
      .rd_rst     (rd_rst),           //读端口复位: 复位读地址,清空读FIFO

      //用户控制端口    
      .sdram_read_valid (read_valid),  //sdram 读使能
      .sdram_init_done  (init_end),    //sdram 初始化完成标志
      .sdram_pingpang_en(pingpang_en), //sdram 乒乓操作使能

      //SDRAM 控制器写端口
      .sdram_wr_req (sdram_wr_req),   //sdram 写请求
      .sdram_wr_ack (sdram_wr_ack),   //sdram 写响应
      .sdram_wr_addr(sdram_wr_addr),  //sdram 写地址
      .sdram_din    (sdram_din),      //写入sdram中的数据

      //SDRAM 控制器读端口
      .sdram_rd_req (sdram_rd_req),   //sdram 读请求
      .sdram_rd_ack (sdram_rd_ack),   //sdram 读响应
      .sdram_rd_addr(sdram_rd_addr),  //sdram 读地址
      .sdram_dout   (sdram_dout)      //从sdram中读出的数据
  );

//SDRAM控制器
sdram_controller u_sdram_controller(
    .clk                (sys_clk),          //sdram 控制器时钟
    .rst_n              (sys_rst_n),            //系统复位
    
    //SDRAM 控制器写端口  
    .sdram_wr_req       (sdram_wr_req),     //sdram 写请求
    .sdram_wr_ack       (sdram_wr_ack),     //sdram 写响应
    .sdram_wr_addr      (sdram_wr_addr),    //sdram 写地址
    .sdram_wr_burst     (wr_burst_len),           //写sdram时数据突发长度
    .sdram_din          (sdram_din),        //写入sdram中的数据
    
    //SDRAM 控制器读端口
    .sdram_rd_req       (sdram_rd_req),     //sdram 读请求
    .sdram_rd_ack       (sdram_rd_ack),     //sdram 读响应
    .sdram_rd_addr      (sdram_rd_addr),    //sdram 读地址
    .sdram_rd_burst     (rd_burst_len),           //读sdram时数据突发长度
    .sdram_dout         (sdram_dout),       //从sdram中读出的数据
    
    .sdram_init_done    (init_end),  //sdram 初始化完成标志

    //SDRAM 芯片接口
    .sdram_cke          (sdram_cke),        //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n),       //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n),      //SDRAM 行有效 
    .sdram_cas_n        (sdram_cas_n),      //SDRAM 列有效
    .sdram_we_n         (sdram_we_n),       //SDRAM 写有效
    .sdram_ba           (sdram_ba),         //SDRAM Bank地址
    .sdram_addr         (sdram_addr),       //SDRAM 行/列地址
    .sdram_data         (sdram_dq)        //SDRAM 数据  
    );
    sdram u_sdram(
    	.clk   (sdram_clk   ),
        .ras_n (sdram_ras_n ),
        .cas_n (sdram_cas_n ),
        .we_n  (sdram_we_n  ),
        .addr  (sdram_addr  ),
        .ba    (sdram_ba    ),
        .dq    (sdram_dq    ),
        .cs_n  (sdram_cs_n  ),
        .dm0   (1'b0        ),
        .dm1   (1'b0        ),
        .dm2   (1'b0        ),//*屏蔽高位，只使用低16位
        .dm3   (1'b0        ),//*屏蔽高位，只使用低16位
        .cke   (sdram_cke   )
    );
    
endmodule
