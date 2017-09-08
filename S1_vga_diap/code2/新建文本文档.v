// 640*480分辨率的VGA彩条显示程序

module VGA(clk,rst_n,vga_hs,vga_vs,vga_r,vga_g,vga_b,blank,data);
        input clk;      //时钟输入25.2MHz
        input rst_n;   //复位信号
        output vga_hs; //行同步信号
        output vga_vs; //场同步信号
         
        input [15:0] data;
        output blank;//空白数据输出
        // R、G、B信号输出 16位色图像数据输出
        output [4:0] vga_r;
        output [5:0] vga_g;
        output [4:0] vga_b;
 //--------------------------------------------------
 reg[10:0] x_cnt;     //行坐标（这里包括了行同步、后沿、有效数据区、前沿）
 reg[9:0] y_cnt;     //列坐标（这里包括了场同步、后沿、有效数据区、前沿）
//reg[5:0] Xcoloradd;
//reg[2:0] Ycoloradd;
 
parameter
 a_x=11'd16,//行显示的前场像素数
 b_x=11'd96,//行同步的像素数
 c_x=11'd48,//行显示的后场像素数
 d_x=11'd640,//行有效的像素个数
 a_y=10'd10,//列显示的前场行数
 b_y=10'd2,//列同步的行数
 c_y=10'd33,//列显示的后场行数
 d_y=10'd480;//列有效的行数
//处理行像素的边界   
always @ (posedge clk or negedge rst_n)
       if(!rst_n) x_cnt <= 10'd0;
      else if(x_cnt == a_x+b_x+c_x+d_x) x_cnt <= 11'd0;          //行计数记到1040
else x_cnt <= x_cnt+1'b1;
 
 //处理列像素的边界
 always @ (posedge clk or negedge rst_n)
       if(!rst_n) y_cnt <= 10'd0;
      else if(y_cnt == a_y+b_y+c_y+d_y) y_cnt <= 10'd0;            //场同步记到666
       else if(x_cnt == 11'd800) y_cnt <= y_cnt+1'b1;//每计数完一行，场同步就加一

//---------------------------------------------------
 
wire valid;     //有效数据显示区标志，就是你在液晶屏幕上可以看到的区域

assign valid = (x_cnt > b_x+c_x) && (x_cnt < b_x+c_x+d_x)
 
          && (y_cnt > b_y+c_y) && (y_cnt < b_y+c_y+d_y);
assign blank=valid;//valid无效时输出空白信号。
//--------------------------------------------------
reg vga_hs_r,vga_vs_r;//行，场同步信号
 
always @ (posedge clk or negedge rst_n)
  if (!rst_n) 
  begin
    vga_hs_r <= 1'b0;
    vga_vs_r <= 1'b0;
  end
  else 
  begin
    vga_hs_r <= x_cnt >=b_x; //产生vga_hs信号（行同步）when x_cnt>=50,then vga_hs_r=1,else 0;低电平同步
    vga_vs_r <= y_cnt >= b_y;  //产生vga_vs信号（场同步）my LCD is low sync
  end


assign vga_hs = vga_hs_r;
assign vga_vs = vga_vs_r;

//--------------------------------------------------
//颜色输出
wire [2:0] num=(x_cnt-144)/80;
assign vga_r={5{num[0]}};
assign vga_g={6{num[1]}};
assign vga_b={5{num[2]}};

endmodule