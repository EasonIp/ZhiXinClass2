//模块文件名：IIC.v
//模块功能：实现IIC总线协议控制
// 用task代替其中的一些操作
//时间：2017-8-10


module IIC_V2 (
    input clk,    // Clock  50M
    input rst_n,  // Asynchronous reset active low
    input key_wr,
    input key_rd,
    input [23:0]data_IIC,    //  input data
    output reg scl,  //串行时钟信号
    inout  sda,  //
    output reg led,    // led==0 亮表明数据写入完毕
    output reg [23:0]result    //output data
);


    reg [9:0] cnt;
    parameter Cnt_num = 50_000_000 / 780_000 /2 -1;   //  31.05
//   390K * 2
    
    reg clk_sys;
    reg [11:0] state;
    //  generate system clock
    always @(posedge clk or negedge rst_n) 
    begin : proc_clk
        if(~rst_n) begin
            cnt <= 0;
            clk_sys <= 0;
        end else begin
             if(cnt < Cnt_num) begin
                 cnt <= cnt + 1;
             end else begin
                 cnt <= 0;
                 clk_sys <= ~clk_sys;
             end
        end
    end

 always @(negedge clk_sys or negedge rst_n) 
    begin : proc_clk2
        if(~rst_n) begin
            scl <= 0;
        end else begin
                if( (state != 0) ) begin
                    scl <= ~scl;
                end else
                    scl <= 1;
             end
    end


    reg sda_en;//sda数据总线控制位
    reg sda_buf; //sda数据输出寄存器
    assign sda = sda_en ? sda_buf : 1'bz;  // 三态门，inout


    reg key_rd_reg, key_wr_reg;
    reg [7:0]address;
    reg [7:0]data;
    reg [7:0]control;

    reg [3:0]counter;

    reg key_clr_wr;
    reg key_clr_rd;

always @(posedge clk or negedge rst_n)    //  clk   不是clk_sys
// always @(*) 
begin : proc_key1
    if(~rst_n) begin
        key_rd_reg<= 0;
        key_wr_reg<= 0;
    end else begin
        if( (key_rd == 0)) begin
            key_rd_reg <= 1;
        end 
        if( (key_wr == 0)) begin
            key_wr_reg <= 1;
        end 
        if(key_clr_wr) begin
            
            key_wr_reg<= 0;
        end 
        if(key_clr_rd) begin
             key_rd_reg<= 0;
        end
    end
end  //proc_key1


always @(posedge clk_sys or negedge rst_n) 
    begin : proc_state
        if(~rst_n) begin
            Initial_reset;
        end else begin
            case(state)
 // 0 状态判断按键是否按下，并给key给值；当有键按下并且串行时钟信号为高的时候，准备发送启动信号
 //准备发送启动信号，这一阶段对应Idel阶段，就是datasheet中P5中A condition；此时sda要给出的状态是1
 //因为fpga要控制总线，所以sda_en要打开
                0   : 
                    begin
                        // if( (key_rd == 0)) begin
                        //     key_rd_reg <= 1;
                        // end
                        // if( (key_wr == 0)) begin
                        //     key_wr_reg <= 1;
                        // end
                         	sda_buf <= 1;  //sda 缓存器 缓存sda的输出，或者高阻，sda_en
                            sda_en <= 1;  //要写入启动信号了，sda下降沿；打开fpga总线控制权
                        if( (key_rd_reg || key_wr_reg) && (scl == 1) ) begin
                            state <= 1;
                            sda_buf <= 1;  //sda 缓存器 缓存sda的输出，或者高阻，sda_en
                            sda_en <= 1;  //要写入启动信号了，sda下降沿；打开fpga总线控制权

                        end
                    end
// 1 串行时钟为高期间，使sda由高变低，启动串行传输
// 对应datasheet P5 的B condition
                1   : 
                    begin
                        if(scl == 1) begin
                            sda_buf <= 0;
                            state <= 2;
                            // sda_en <= 1;   //此时sda要给一个低电平，前面sda_en已经打开，后面不用操作
                            // sda_buf <= 0;
                            control <= 8'b10100000; //写控制字准备
                        end
                    end
// 2  send control word； 在scl低电平期间，完成串并转换，发出写控制字（一位一位地）
//   对应datasheet P5中4-1灰色区域，sda信号写数据的时候是scl为低电平的状态
                2   : 
                    begin
                        if( (counter < 8)&&(scl == 0) ) begin
                            counter <= counter + 1;
                            control <= {control[6:0],control[7]};
                            sda_buf <= control[7];  //因为前面sda_en打开后一直没有释放，所以直接写就可以了
                        end
                        else if( (counter == 8)&& (scl == 0) ) begin
                            counter <= 0;
                            state <= 3;
                            sda_en <= 0;  //释放总线控制权，因为要等待应答
                        end
                    end
// 3  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
//ack 信号是在fpga释放sda总线控制之后sda上给出的的in信号，低电平为ack  datasheet中P9 的8-2
                3   : 
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                               state <= 4;
                               address <= 8'b00000000;  //高地址位准备
                            end
                        end
                    end
// 4  send low byte addr   scl在低电平期间完成并串转换，发出高字节地址
                4   : 
                    begin
                        // if(scl == 0) begin
                        //    if(counter < 8) begin
                        //        /* code */
                        //    end
                        // end
                        if( (scl == 0)&&(counter < 8) ) begin
                            counter <= counter +1;
                            address <= {address[6:0],address[7]};
                            sda_en <= 1;
                            sda_buf <= address[7];
                        end 
                        else if( (scl == 0)&&(counter == 8)) begin
                            counter <= 0;
                            sda_en <= 0;
                            state <= 5;
                            // sda_buf <= ???;
                        end 
                    end
// 5  receive ack signal   scl在高电平期间，检测是否有应答信号
                5   : 
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                               state <= 6;
                               address <= 8'b00000101;  //低地址位准备
                            end
                        end
                    end
// 6  send low byte addr   scl在低电平期间完成并串转换，发出低字节地址
                6   : 
                    begin
                        if( (scl == 0)&&(counter < 8) ) begin
                            counter <= counter +1;
                            address <= {address[6:0],address[7]};
                            sda_en <= 1;
                            sda_buf <= address[7];
                        end 
                        else if( (scl == 0)&&(counter == 8)) begin
                            counter <= 0;
                            sda_en <= 0;
                            state <= 7;
                            sda_buf <= 1;  //??  准备读或写
                        end 
                    end
// 7  receive ack    中间判断是跳转随机读还是随机写时序
                7   : 
                    begin
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                               if(key_wr_reg ==1) begin
                                   state <= 8;
                                    data <= data_IIC[7:0];
                               end
                               if(key_rd_reg ==1) begin
                                   state <= 11;
                                   sda_buf <= 1; //准备再次发送启动信号
                               end
                               // data <= 8'b00001111;  //准备要随机写入的数据
                               // data <= data_IIC[7:0];  //准备要随机写入的数据
                            end
                        end
                    end
                    end
// 8  send active data  在scl低电平期间，完成并串转换，发出有效数据
                8   : 
                    begin
                         // data <= data_IIC[7:0];     //放在这里是显示不了第一个数，显示的是0
                        if( (counter < 8)&&(scl == 0) ) begin
                            counter <= counter +1;
                            sda_en <= 1;
                            data <= {data[6:0],data[7]};
                            sda_buf <= data[7];
                        end 
                        else if( (counter == 8)&&(scl==0) ) begin
                            counter <= 0;
                            state <= 9;
                            sda_en <= 0; //释放总线控制权，等待应答

                        end
                    end
// 9  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
                9   : 
                    begin
                       
                        if( (scl == 1)&&(sda == 0) ) begin

                            
                               // state <= 10;
                               state <= 18;
                               data[7:0] <= data_IIC[15:8];  //准备要随机写入的数据
                               sda_en <= 1;

                       
                        end
                    end
// 18  send active data  在scl低电平期间，完成并串转换，发出有效数据
                18   : 
                    begin
                    	
                        if( (counter < 8)&&(scl==0) ) begin
                            counter <= counter +1;
                            // sda_en <= 1;
                            data <= {data[6:0],data[7]};
                            sda_buf <= data[7];
                        end 
                        else if( (counter == 8)&&(scl==0) ) begin
                            counter <= 0;
                            state <= 19;
                            sda_en <= 0; //释放总线控制权，等待应答
                            led <= 0;

                        end
                    end
// 19  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
                19   : 
                    begin
                    		// sda_en <= 0;
                         if( (scl == 1)&&(sda == 0) ) 
                         begin
                               state <= 28;
                               sda_en <= 0; //释放总线控制权
                               data <= data_IIC[15:8] + data_IIC[7:0];  //准备要随机写入的数据

                         end
                    end

// 28  send active data  在scl低电平期间，完成并串转换，发出有效数据
                28   : 
                    begin
                        if( (counter < 8)&&(scl==0) ) begin
                            counter <= counter +1;
                            sda_en <= 1;
                            data <= {data[6:0],data[7]};
                            sda_buf <= data[7];
                        end 
                        else if( (counter == 8)&&(scl==0) ) begin
                            counter <= 0;
                            state <= 29;
                            sda_en <= 0; //释放总线控制权，等待应答
                            
                        end
                    end
// 29  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
                29   : 
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                               state <= 10;
                               sda_en <= 1; 
                            end
                        end
                    end
// 10 send stop signal  scl高电平期间，拉高sda   点亮led说明写完成了  按键放开后才跳转空闲状态，避免不断循环写入，清除写控制标志
                10   : 
                    begin
                        // sda_en <= 1;
                        // sda_buf <= 0;
                        if(scl == 1) begin
                          
                            sda_buf <= 1;
                            if(key_wr && key_rd) begin
                                state <= 0;
                                key_clr_wr <= 1;
                                // key_rd_reg <=0;
                            end
                        end
                    end
// 11 send start signal    scl高点平期间拉低sda，发送启动信号
                11   : 
                    begin
                        sda_en <= 1;
                        if(scl ==1) begin
                            // sda <= 0;   //没有直接给他赋值，都是通过buf和en
                            sda_buf <= 0;
                            state <= 12;
                            control <= 8'b10100001;
                        end
                    end
// 12 send control word   在scl低电平期间，完成并串转换，发出读控制字
                12   : 
                    begin
                       if( (counter <8)&&(scl ==0) ) begin
                          counter <= counter +1;
                          control <= {control[6:0],control[7]};
                          // sda <= control[7];   //没有直接给他赋值，都是通过buf和en
                          sda_buf <= control[7];
                       end else
                       if( (counter == 8)&&(scl ==0) ) begin
                           counter <= 0;
                           sda_en <= 0;
                           state <= 13;
                       end
                    end
// 13 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
                13   : 
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                                state <= 14;
                                sda_en <= 0;  //
                            end
                        end
                    end
// 14 receive input active data  在scl高电平期间，完成串并转换，存储接收数据  接收后fpga继续控制总线
                14   : 
                    begin
                        if( (scl ==1)&&(counter < 8) ) begin
                            
                            counter <= counter +1;
                            data[7-counter] <= sda;
                            // result[7-counter] <= sda;
                        end
                        else if( (scl ==1)&&(counter == 8) ) begin
                            counter <= 0;
                            // state <= 15;
                            state <= 17;
                            sda_en <= 1;    
                            // sda_buf <= 0;
                        end
                    end
               17   :
                    begin
                            result[7:0] <= data[7:0];
                            result[15:8] <= 8'd12;
                            // result[23:16] <= result[7:0] + result[15:8] ;  //  ==0
                            result[23:16] <=  data[7:0] + 8'd12;  //  ==0

                            state <= 23;
                            sda_en <= 0;
                            // sda_buf <= 1;

                    end
// 23 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
                23   :
                    begin
                        if( (scl == 1)&&(sda == 0) )  
                        begin
                            
                                state <= 24;
                                // sda_en <= 0;  //
                         end
                    end
// 24 receive input active data  在scl高电平期间，完成并串转换，存储接收数据  接收后fpga继续控制总线
                24   : 
                    begin
                        if( (scl ==1)&&(counter < 8) ) begin
                            counter <= counter +1;
                            data[7-counter] <= sda;
                            // result[7-counter] <= sda;
                        end
                        else if( (scl ==1)&&(counter == 8) ) begin
                            counter <= 0;
                            // state <= 15;
                            state <= 217;
                            sda_en <= 1;    //接受完了之后继续控制总线
                            sda_buf <= 1;

                        end
                    end
               217   :
                    begin
                            result[15:8] <= data[7:0];
                            // result[15:8] <= 8'd2;
                            // result[15:8] <= 8'd7;
                            state <= 33;
                             sda_en <= 0;
                    end
// 33 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
                33   : 
                    begin
                        if(scl == 1) begin
                            if(sda == 0) begin
                                state <= 34;
                                // sda_en <= 1;  //
                            end
                        end
                    end
// 34 receive input active data  在scl高电平期间，完成串并转换，存储接收数据  接收后fpga继续控制总线
                34   : 
                    begin
                        if( (scl ==1)&&(counter < 8) ) begin
                            
                            counter <= counter +1;
                            data[7-counter] <= sda;
                            // result[7-counter] <= sda;
                        end
                        else if( (scl ==1)&&(counter == 8) ) begin
                            counter <= 0;
                            // state <= 15;
                            state <= 317;
                            sda_en <= 1;    //接受完了之后继续控制总线
                            sda_buf <= 1;
                        end
                    end
               317   :
                    begin
                            // result[23:16] <= data[7:0];
                             // result[15:8] <=  1;
                            // result[23:16] <= 8'd3;
                            state <= 15;
                            sda_en <= 1;
                    end

// 15 send no ack signal  在scl高电平期间，将sda总线拉高，发出非应答信号
                15   : 
                    begin
                        if(scl == 1) begin
                            sda_buf <=1;
                            state <= 16;
                        end
                    end
// 16 send stop signal    在scl 低电平期间，将sda总线拉低，准备发送停止信号； 在scl高电平期间，将sda总线拉高，发出停止信号
                16   : 
                    begin
                        if(scl == 0) begin
                            sda_buf <= 0;
                        end
                        if(scl == 1) begin
                            sda_buf <= 1;
                            state <= 0;
                            key_clr_rd <= 1;
                           
                        end
                    end

//default   状态跳转到0
                default   : state <= 0;

            endcase
        end



 end// end proc

task Initial_reset;
	begin
		state <= 0;
        sda_buf <= 1;
        sda_en<= 1;
        key_clr_rd <= 0;
        key_clr_wr <= 0;
        address <= 0;
        data <= 0;
        led <=1;
        control <= 0;
        counter <= 0;
        result <= 0;
    end
endtask

endmodule
//   sda_en的状态在收发数据的时候要 给定控制总线sda的使能，到底是fpga占用还是释放，写完1byte后ack时候要释放sda控制权

// 0 状态判断按键是否按下，并给key给值；当有键按下并且串行时钟信号为高的时候，准备发送启动信号
// 1 串行时钟为高期间，使sda由高变低，启动串行传输
// 2  send control word； 在scl低电平期间，完成串并转换，发出写控制字（一位一位地）
// 3  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
// 4  send low byte addr   scl在低电平期间完成并串转换，发出高字节地址
// 5  receive ack signal   scl在高电平期间，检测是否有应答信号
// 6  send low byte addr   scl在低电平期间完成并串转换，发出低字节地址
// 7  receive ack    中间判断是跳转随机读还是随机写时序
// 8  send active data  在scl低电平期间，完成并串转换，发出有效数据
// 9  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
// 10 send stop signal  scl高电平期间，拉高sda   点亮led说明写完成了  按键放开后才跳转空闲状态，避免不断循环写入，清除写控制标志
// 11 send start signal    scl高点平期间拉低sda，发送启动信号
// 12 send control word   在scl低电平期间，完成并串转换，发出读控制字
// 13 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
// 14 receive input active data  在scl高电平期间，完成串并转换，存储接收数据  接收后fpga继续控制总线
// 15 send no ack signal  在scl高电平期间，将sda总线拉高，发出非应答信号
// 16 send stop signal    在scl 低电平期间，将sda总线拉低，准备发送停止信号； 在scl高电平期间，将sda总线拉高，发出停止信号

//default   状态跳转到0




// //模块文件名：IIC.v
// //模块功能：实现IIC总线协议控制
// //时间：2017-8-9


// module IIC_24LC64 (
//     input clk,    // Clock  50M
//     input rst_n,  // Asynchronous reset active low
//     input key_wr,
//     input key_rd,
//     output reg scl,  //串行时钟信号
//     inout  sda,  //
//     output reg led,    // led==0 亮表明数据写入完毕
//     output reg led2,
//     output reg [7:0]result
// );


//     reg [9:0] cnt;
//     parameter Cnt_num = 50_000_000 / 780_000 /2 -1;   
// //   390K * 2
    
//     reg clk_sys;
//         reg [7:0] state;
//     //  generate system clock
//     always @(posedge clk or negedge rst_n) 
//     begin : proc_clk
//         if(~rst_n) begin
//             cnt <= 0;
//             clk_sys <= 0;
//         end else begin
//              if(cnt < Cnt_num) begin
//                  cnt <= cnt + 1;
//              end else begin
//                  cnt <= 0;
//                  clk_sys <= ~clk_sys;
//              end
//         end
//     end

//  always @(negedge clk_sys or negedge rst_n) 
//     begin : proc_clk2
//         if(~rst_n) begin
//             scl <= 0;
//         end else begin
//                 if( (state !=0) )
//                     scl <= ~scl;
//                 else
//                     scl <= 1;
//              end
//     end


//     reg sda_en;//sda数据总线控制位
//     reg sda_buf; //sda数据输出寄存器
//     assign sda = sda_en ? sda_buf : 1'bz;  // 三态门，inout


//     reg key_rd_reg, key_wr_reg;
//     reg [7:0]address;
//     reg [7:0]data;
//     reg [7:0]control;

//     reg [3:0]counter;

//     reg key_clr_wr;
//     reg key_clr_rd;

// always @(posedge clk_sys or negedge rst_n) 
// // always @(*) 
// begin : proc_key1
//     if(~rst_n) begin
//         key_rd_reg<= 0;
//         key_wr_reg<= 0;
//     end else begin
//         if( (key_rd == 0)) begin
//             key_rd_reg <= 1;
//         end 
//         if( (key_wr == 0)) begin
//             key_wr_reg <= 1;
//         end 
//         if(key_clr_wr) begin
            
//             key_wr_reg<= 0;
//         end 
//         if(key_clr_rd) begin
//              key_rd_reg<= 0;
//         end
//     end
// end  //proc_key1


//     always @(posedge clk_sys or negedge rst_n) 
//     begin : proc_state
//         if(~rst_n) begin
//             state <= 0;
//             sda_buf <= 0;
//             sda_en<= 0;
//            key_clr_rd <= 0;
//            key_clr_wr <= 0;
//             address <= 0;
//             data <= 0;
//             control <= 0;
//             counter <= 0;
//             led <= 1;
//             led2 <= 1;
//         end else begin
//             case(state)
//  // 0 状态判断按键是否按下，并给key给值；当有键按下并且串行时钟信号为高的时候，准备发送启动信号
//  //准备发送启动信号，这一阶段对应Idel阶段，就是datasheet中P5中A condition；此时sda要给出的状态是1
//  //因为fpga要控制总线，所以sda_en要打开
//                 0   : 
//                     begin
//                         // if( (key_rd == 0)) begin
//                         //     key_rd_reg <= 1;
//                         // end
//                         // if( (key_wr == 0)) begin
//                         //     key_wr_reg <= 1;
//                         // end
//                          sda_buf <= 1;  //sda 缓存器 缓存sda的输出，或者高阻，sda_en
//                          sda_en <= 1;  //要写入启动信号了，sda下降沿；打开fpga总线控制权
//                         if( (key_rd_reg || key_wr_reg) && (scl == 1) ) begin
//                             state <= 1;
//                             sda_buf <= 1;  //sda 缓存器 缓存sda的输出，或者高阻，sda_en
//                             sda_en <= 1;  //要写入启动信号了，sda下降沿；打开fpga总线控制权
//                             // sda_buf <= 1;


//                         end
//                     end
// // 1 串行时钟为高期间，使sda由高变低，启动串行传输
// // 对应datasheet P5 的B condition
//                 1   : 
//                     begin
//                         if(scl == 1) begin
//                             sda_buf <= 0;
//                             state <= 2;
//                             // sda_en <= 1;   //此时sda要给一个低电平，前面sda_en已经打开，后面不用操作
//                             control <= 8'b10100000; //写控制字准备

//                         end
//                     end
// // 2  send control word； 在scl低电平期间，完成串并转换，发出写控制字（一位一位地）
// //   对应datasheet P5中4-1灰色区域，sda信号写数据的时候是scl为低电平的状态
//                 2   : 
//                     begin
//                         if( (counter < 8)&&(scl == 0) ) begin
//                             counter <= counter + 1;
//                             data <= {data[6:0],data[7]};
//                             sda_buf <= data[7];  //因为前面sda_en打开后一直没有释放，所以直接写就可以了
//                         end
//                         else if( (counter == 8)&& (scl == 0) ) begin
//                             counter <= 0;
//                             state <= 3;
//                             sda_en <= 0;  //释放总线控制权，因为要等待应答

//                         end
//                     end
// // 3  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
// //ack 信号是在fpga释放sda总线控制之后sda上给出的的in信号，低电平为ack  datasheet中P9 的8-2
//                 3   : 
//                     begin
//                         if(scl == 1) begin
//                             if(sda == 0) begin
//                                state <= 4;
//                                address <= 8'b00000000;  //高地址位准备

//                             end
//                         end
//                     end
// // 4  send low byte addr   scl在低电平期间完成并串转换，发出高字节地址
//                 4   : 
//                     begin
//                         // if(scl == 0) begin
//                         //    if(counter < 8) begin
//                         //        /* code */
//                         //    end
//                         // end
//                         if( (scl == 0)&&(counter < 8) ) begin
//                             counter <= counter +1;
//                             address <= {address[6:0],address[7]};
//                             sda_en <= 1;
//                             sda_buf <= address[7];
//                         end 
//                         else if( (scl == 0)&&(counter == 8)) begin
//                             counter <= 0;
//                             sda_en <= 0;
//                             state <= 5;
//                              led2 <= 0;
//                             // sda_buf <= ???;
//                         end 
//                     end
// // 5  receive ack signal   scl在高电平期间，检测是否有应答信号
//                 5   : 
//                     begin
//                         if(scl == 1) begin
//                             if(sda == 0) begin
//                                state <= 6;
//                                address <= 8'b00000011;  //低地址位准备

//                             end
//                         end
//                     end
// // 6  send low byte addr   scl在低电平期间完成并串转换，发出低字节地址
//                 6   : 
//                     begin
//                         if( (scl == 0)&&(counter < 8) ) begin
//                             counter <= counter +1;
//                             address <= {address[6:0],address[7]};
//                             sda_en <= 1;
//                             sda_buf <= address[7];
//                         end 
//                         else if( (scl == 0)&&(counter == 8)) begin
//                             counter <= 0;
//                             sda_en <= 0;
//                             state <= 7;
//                             sda_buf <= 1;  //??  准备读或写

//                         end 
//                     end
// // 7  receive ack    中间判断是跳转随机读还是随机写时序
//                 7   : 
//                     begin
//                     begin
//                         if(scl == 1) begin
//                             if(sda == 0) begin
//                                if(key_wr_reg ==1) begin
//                                    state <= 8;
//                                end
//                                if(key_rd_reg ==1) begin
//                                    state <= 11;
//                                    sda_buf <= 1; //准备再次发送启动信号
//                                end
//                                data <= 8'b00001111;  //准备要随机写入的数据
//                             end
//                         end
//                     end
//                     end
// // 8  send active data  在scl低电平期间，完成并串转换，发出有效数据
//                 8   : 
//                     begin
//                         if( (counter < 8)&&(scl==0) ) begin
//                             counter <= counter +1;
//                             sda_en <= 1;
//                             data <= {data[6:0],data[7]};
//                             sda_buf <= data[7];
//                         end 
//                         else if( (counter == 8)&&(scl==0) ) begin
//                             counter <= 0;
//                             state <= 9;
//                             sda_en <= 0; //释放总线控制权，等待应答
//                         end
//                     end
// // 9  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
//                 9   : 
//                     begin
//                         if(scl == 1) begin
//                             if(sda == 0) begin
//                                state <= 10;
//                             end
//                         end
//                     end
// // 10 send stop signal  scl高电平期间，拉高sda   点亮led说明写完成了  按键放开后才跳转空闲状态，避免不断循环写入，清除写控制标志
//                 10   : 
//                     begin
//                         sda_en <= 1;
//                         sda_buf <= 0;
//                         if(scl == 1) begin
//                             led <= 0;
//                             sda_buf <= 1;
//                             if(key_wr && key_rd) begin
//                                 state <= 0;
//                                 key_clr_wr <= 1;
//                                 // key_rd_reg <=0;
//                             end
//                         end
//                     end
// // 11 send start signal    scl高点平期间拉低sda，发送启动信号
//                 11   : 
//                     begin
//                         sda_en <= 1;
//                         if(scl ==1) begin
//                             // sda <= 0;   //没有直接给他赋值，都是通过buf和en
//                             sda_buf <= 0;
//                             state <= 12;
//                             control <= 8'b10100001;
//                         end
//                     end
// // 12 send control word   在scl低电平期间，完成并串转换，发出读控制字
//                 12   : 
//                     begin
//                        if( (counter <8)&&(scl ==0) ) begin
//                           counter <= counter +1;
//                           control <= {control[6:0],control[7]};
//                           // sda <= control[7];   //没有直接给他赋值，都是通过buf和en
//                           sda_buf <= control[7];
//                        end else
//                        if( (counter == 8)&&(scl ==0) ) begin
//                            counter <= 0;
//                            sda_en <= 0;
//                            state <= 13;
//                        end
//                     end
// // 13 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
//                 13   : 
//                     begin
//                         if(scl == 1) begin
//                             if(sda == 0) begin
//                                 state <= 14;
//                             end
//                         end
//                     end
// // 14 receive input active data  在scl高电平期间，完成串并转换，存储接收数据  接收后fpga继续控制总线
//                 14   : 
//                     begin
//                         if( (scl ==1)&&(counter < 8) ) begin
//                              sda_en <= 1;  
//                             counter <= counter +1;
//                             data[7-counter] <= sda;
//                         end
//                         else if( (scl ==1)&&(counter == 8) ) begin
//                             counter <= 0;
//                             // state <= 15;
//                             state <= 17;
//                             sda_en <= 1;    //接受完了之后继续控制总线
//                             sda_buf <= 1;
//                         end
//                     end

//                 17:   begin
//                             result <= data;
                            
//                             state <= 15;
//                         end
// // 15 send no ack signal  在scl高电平期间，将sda总线拉高，发出非应答信号
//                 15   : 
//                     begin
//                         if(scl == 1) begin
//                             sda_buf <=1;
//                             state <= 16;
//                         end
//                     end

// // 16 send stop signal    在scl 低电平期间，将sda总线拉低，准备发送停止信号； 在scl高电平期间，将sda总线拉高，发出停止信号
//                 16   : 
//                     begin
//                         if(scl == 0) begin
//                             sda_buf <= 0;
//                         end
//                         if(scl == 1) begin
//                             sda_buf <= 1;
//                             state <= 0;
//                             key_clr_rd <= 1;
//                         end
//                     end

// //default   状态跳转到0
//                 default   : state <= 0;

//             endcase
//         end
//     end// end proc
// //   sda_en的状态在收发数据的时候要 给定控制总线sda的使能，到底是fpga占用还是释放，写完1byte后ack时候要释放sda控制权

// // 0 状态判断按键是否按下，并给key给值；当有键按下并且串行时钟信号为高的时候，准备发送启动信号
// // 1 串行时钟为高期间，使sda由高变低，启动串行传输
// // 2  send control word； 在scl低电平期间，完成串并转换，发出写控制字（一位一位地）
// // 3  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
// // 4  send low byte addr   scl在低电平期间完成并串转换，发出高字节地址
// // 5  receive ack signal   scl在高电平期间，检测是否有应答信号
// // 6  send low byte addr   scl在低电平期间完成并串转换，发出低字节地址
// // 7  receive ack    中间判断是跳转随机读还是随机写时序
// // 8  send active data  在scl低电平期间，完成并串转换，发出有效数据
// // 9  receive ack signal   scl在高电平期间，检测是否有应答信号，有应答信号就跳转
// // 10 send stop signal  scl高电平期间，拉高sda   点亮led说明写完成了  按键放开后才跳转空闲状态，避免不断循环写入，清除写控制标志
// // 11 send start signal    scl高点平期间拉低sda，发送启动信号
// // 12 send control word   在scl低电平期间，完成并串转换，发出读控制字
// // 13 receive ack signal   在scl高电平期间，检测有无应答信号，有应答就继续跳转
// // 14 receive input active data  在scl高电平期间，完成串并转换，存储接收数据  接收后fpga继续控制总线
// // 15 send no ack signal  在scl高电平期间，将sda总线拉高，发出非应答信号
// // 16 send stop signal    在scl 低电平期间，将sda总线拉低，准备发送停止信号； 在scl高电平期间，将sda总线拉高，发出停止信号

// //default   状态跳转到0

// endmodule