# AN5640 项目说明

目的
- 将 AN5640 摄像头采集的 1920×768 图像写入开发板上的 SDRAM，然后通过 HDMI 接口将图像传输到 LCD 显示屏显示。

目录结构（节选）
- `pic_sdram.al` / `top.adc` / `top.sdc`：Quartus 项目与时序约束文件。
- `al_ip/`：包含 SDRAM、PLL、视频相关 IP（例如 `sdram.v`、`sys_pll.v`、`video_pll.v` 等）。
- `db/`, `incremental_db/`, `output_files/`, `pic_sdram_Runs/`：Quartus 生成的中间/输出目录。
- `log/`：工具运行日志。
- `src/`：可能包含顶层或自定义源（视项目而定）。


硬件连线与时钟
- 摄像头（AN5640）引脚应连接到工程中定义的视频输入引脚，注意时钟（摄像头提供的像素时钟）与同步信号（VSYNC/HSYNC）。
- 工程中通常使用 `video_pll` / `sys_pll` 提供显示与 SDRAM 时钟，检查 `al_ip` 中的 PLL 配置并确认时序约束（`top.sdc` / `top.adc`）。
- SDRAM 接线必须与 `sdram.v` 的引脚一一对应，注意数据宽度、地址线和时序参数。

详细引脚信息位于[top.sdc]

```sdc
set_pin_assignment { cam_data[0] } { LOCATION = E15; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[1] } { LOCATION = L10; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[2] } { LOCATION = K15; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[3] } { LOCATION = J16; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[4] } { LOCATION = D16; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[5] } { LOCATION = M10; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[6] } { LOCATION = G16; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_data[7] } { LOCATION = G14; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_href } { LOCATION = F14; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_pclk } { LOCATION = H16; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_pwdn } { LOCATION = M14; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }
set_pin_assignment { cam_rst_n } { LOCATION = P11; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }
set_pin_assignment { cam_scl } { LOCATION = M16; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }
set_pin_assignment { cam_sda } { LOCATION = K16; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }
set_pin_assignment { cam_vsync } { LOCATION = H15; IOSTANDARD = LVCMOS33; PULLTYPE = NONE; }
set_pin_assignment { cam_xclk } { LOCATION = F15; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }
```
> [!tip]
> 同时注意AN5640不同于OV5640,AN5640没有内部晶振，需要为AN5640dxclk信号的提供稳定时钟
> `set_pin_assignment { cam_xclk } { LOCATION = F15; IOSTANDARD = LVCMOS33; DRIVESTRENGTH = 8; PULLTYPE = NONE; }`

