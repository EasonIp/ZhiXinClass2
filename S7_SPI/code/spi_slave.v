//=============================================================================
//     spi_slave 功能模块
// --------------------------
// 2015-11-28 LC V1.0
// 建立模块，定义16个寄存器，完成读写仿真
// 
//=============================================================================
module spi_slave
    (
      input  wire        spi_ss     ,
      input  wire        spi_sclk   ,
      inout  wire        spi_sda
    );
  
//============================================================================= 

  reg  [4:0]  cnt_clk     ;   // clock count
  reg         flag        ;   // W/R flag
  reg         out_en      ;   // out enable
  wire        spi_sda_out ;   // sdata out
  reg  [3:0]  addr        ;   // address
  reg  [19:0] rcv_regs    ;   // receive regs
  reg  [19:0] trs_regs    ;   // transmit regs
  
  reg  [19:0] mem[15:0]   ;   // InnerRegs

//=============================================================================

  assign spi_sda_out = trs_regs[19];
  assign spi_sda = out_en ? spi_sda_out : 1'bz;

//=============================================================================

  initial
    begin
      cnt_clk = 0;
      flag = 0;
      out_en = 0;
      addr = 0;
      rcv_regs = 0;
      trs_regs = 0;
    end
  
//=============================================================================
// 时钟计数    32    
  always @ (posedge spi_sclk)
    begin
      if(spi_ss)
        cnt_clk <= cnt_clk + 1'b1;
      else
        cnt_clk <= 5'd0;      
    end
  
// 解析读写标志
  always @ (posedge spi_sclk)
    begin
      if((spi_ss) && (cnt_clk ==5'd0))
        flag <= spi_sda;
      else
        flag <= flag ;
    end
  
// 解析地址
  always @ (posedge spi_sclk)
    begin
      if((spi_ss) && (cnt_clk >5'd0) && (cnt_clk <5'd5))
        addr <= {addr,spi_sda};
      else
        addr <= addr ;
    end
  
//=============================================================================  
// 写操作，完成数据的移入
  always @ (posedge spi_sclk)
    begin
      if((spi_ss) && (cnt_clk >= 5'd5) && (flag == 1'b0))
        rcv_regs <= {rcv_regs[18:0],spi_sda};
      else
        rcv_regs <= rcv_regs ;
    end
  
// 写操作完成后，对数据的存储
  always @ (negedge spi_sclk)
    begin
      if((cnt_clk == 5'd25) && (flag == 1'b0))
        mem[addr] <= rcv_regs;
    end
  
//=============================================================================  
// 读操作
  always @ (negedge spi_sclk)
    begin
      if((spi_ss) && (cnt_clk == 5'd6) && (flag == 1'b1))
        trs_regs <= mem[addr];
      else if((spi_ss) && (cnt_clk > 5'd7) && (cnt_clk < 5'd27) && (flag == 1'b1))
        trs_regs <= {trs_regs[18:0],1'b0};
      else
        trs_regs <= trs_regs;
    end
  
// 读使能
  always @ (negedge spi_sclk)
    begin
      if((cnt_clk == 5'd7) && (flag == 1'b1))
        out_en <= 1'b1;
      else if((cnt_clk == 5'd27) && (flag == 1'b1))
        out_en <= 1'b0;
      else
        out_en <= out_en;
    end  
  
//=============================================================================


endmodule
