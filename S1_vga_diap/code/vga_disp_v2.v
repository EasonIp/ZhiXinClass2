module vga_disp_v2(
    input clk,
    input rst_n,

    output [7:0]vga_rgb,
    output vga_hs,
    output vga_vs
    );

    reg [2:0] r,
    reg [2:0] g,
    reg [1:0] b,

    assign vga_rgb = {r,g,b};
// 设定边界，决定改变方向与否
    parameter UP_BOUND = 31;
    parameter DOWN_BOUND = 510;
    parameter LEFT_BOUND = 144;
    parameter RIGHT_BOUND = 783;
    // 状态机决定下一次扫描输出的颜色
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    reg [2:0] state, nextstate;
    reg [2:0] nextr, nextg;
    reg [1:0] nextb;
    
    reg h_speed, v_speed;
    reg [9:0] up_pos, down_pos, left_pos, right_pos;
// 行信号和列信号决定着当前像素是否显示出来。该程序选择的是在25Hz下640 * 480的分辨率显示。
// 具体想改变分辨率的，可以在参考网上的资料。VGA的显示是逐行扫描像素点，
// 除了可见区域，还有不可见区域的像素点，因此可以通过边界控制是否输出。
    wire myclk;
    reg [1:0] count;
    reg [9:0] hcount, vcount;
    
    assign myclk = count[1];

    always@(posedge clk)
    begin
        if(rst_n)
            count <= 0;
        else
            count <= count + 1'b1;
    end
    
    assign vga_hs = (hcount < 96) ? 1'b0 : 1'b1;
    always@(posedge myclk or posedge rst_n)
    begin
        if(rst_n)
            hcount <= 0;
        else if(hcount == 799)
            hcount <= 0;
        else
            hcount <= hcount + 1'b1;
    end
    
    assign vga_vs = (vcount < 2) ? 1'b0 : 1'b1;
    always@(posedge myclk or posedge rst_n)
    begin
        if(rst_n)
            vcount <= 0;
        else if(hcount == 799) 
        begin
            if(vcount == 520)
                vcount <= 0;
            else
                vcount <= vcount + 1'b1;
        end
        else
            vcount <= vcount;
    end
    // 彩色变化，通过状态机实现。每一列像素点对应一个颜色，但是方块区域才通过彩色输出，否则输出黑色，形成了彩色轮转。
    always@(posedge myclk or posedge rst_n)
    begin
        if(rst_n) 
        begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
        else begin
            if((vcount >= up_pos) 
            && (vcount <= down_pos)
            && (hcount >= left_pos) 
            && (hcount<=right_pos)) 
            begin
                r <= nextr; 
                g <= nextg; 
                b <= nextb;
            end
            else 
            begin
                r <= 3'b000;
                g <= 3'b000;
                b <= 2'b00;
            end
        end
    end
    
    always@(posedge myclk or posedge rst_n)
    begin
        if(rst_n)
            state <= S0;
        else
            state <= nextstate;
    end
    
    always@(*)
    begin
        case(state)
            S0:     nextstate <= S1;
            S1:     nextstate <= S2;
            S2:     nextstate <= S3;
            S3:     nextstate <= S0;
            default:    nextstate <= S0;
        endcase
    end
    
    always@(*)
    begin
        case(state)
            S0:     begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b00; end
            S1:     begin nextr <= 3'b000; nextg <= 3'b111; nextb <= 2'b00; end
            S2:     begin nextr <= 3'b000; nextg <= 3'b000; nextb <= 2'b11; end
            S3:     begin nextr <= 3'b111; nextg <= 3'b111; nextb <= 2'b00; end
            default:    begin nextr <= 3'b111; nextg <= 3'b000; nextb <= 2'b11; end
        endcase
    end
    // 但列信号由输出变成非输出时触发。在这个情况下，应该处理下一帧的方向和速度。
    always@(negedge vga_vs or posedge rst_n)
    begin
        if(rst_n)
        begin
            h_speed <= 1;
            v_speed <= 0;
        end
        else 
        begin
            if(up_pos == UP_BOUND)
                v_speed <= 1;
            else if(down_pos == DOWN_BOUND)
                v_speed <= 0;
            else
                v_speed <= v_speed;
            
            if (left_pos == LEFT_BOUND)
                h_speed <= 1;
            else if (right_pos == RIGHT_BOUND)
                h_speed <= 0;
            else
                h_speed <= h_speed;
        end
    end
    
    always@(posedge vga_vs or posedge rst_n)
    begin
        if(rst_n) 
        begin
            up_pos <= 391;
            down_pos <= 510;
            left_pos <= 384;
            right_pos <= 543;
        end
        else
        begin
            if(v_speed) 
            begin
                up_pos <= up_pos + 1'b1;
                down_pos <= down_pos + 1'b1;
            end
            else 
            begin
                up_pos <= up_pos - 1'b1;
                down_pos <= down_pos - 1'b1;
            end
            
            if(h_speed)
            begin
                left_pos <= left_pos + 1'b1;
                right_pos <= right_pos + 1'b1;
            end
            else 
            begin
                left_pos <= left_pos - 1'b1;
                right_pos <= right_pos - 1'b1;
            end
        end
    end

endmodule