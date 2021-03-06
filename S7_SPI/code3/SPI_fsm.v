// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// Generated by Quartus II Version 13.0.0 Build 156 04/24/2013 SJ Web Edition
// Created on Sun Aug 13 10:10:53 2017

// synthesis message_off 10175

`timescale 1ns/1ns

module SPI_fsm (
    reset,CLK,Go,bitcount[3:0],
    rstbicount,bitcountEN,SCLK,SCEN,ORDY,LDEN,SHEN);

    input reset;
    input CLK;
    input Go;
    input [3:0] bitcount;
    tri0 reset;
    tri0 Go;
    tri0 [3:0] bitcount;
    output rstbicount;
    output bitcountEN;
    output SCLK;
    output SCEN;
    output ORDY;
    output LDEN;
    output SHEN;
    reg rstbicount;
    reg bitcountEN;
    reg SCLK;
    reg SCEN;
    reg ORDY;
    reg LDEN;
    reg SHEN;
    reg [3:0] fstate;
    reg [3:0] reg_fstate;
    parameter START=0,X_IDLE=1,X_STOP=2,X_SHIFT=3;

    always @(posedge CLK or posedge reset)
    begin
        if (reset) begin
            fstate <= X_IDLE;
        end
        else begin
            fstate <= reg_fstate;
        end
    end

    always @(fstate or Go or bitcount)
    begin
        rstbicount <= 1'b0;
        bitcountEN <= 1'b0;
        SCLK <= 1'b0;
        SCEN <= 1'b0;
        ORDY <= 1'b0;
        LDEN <= 1'b0;
        SHEN <= 1'b0;
        case (fstate)
            START: begin
                reg_fstate <= X_SHIFT;

                LDEN <= 1'b1;

                ORDY <= 1'b0;

                SCEN <= 1'b0;

                SHEN <= 1'b0;

                bitcountEN <= 1'b0;

                SCLK <= 1'b1;
            end
            X_IDLE: begin
                if (Go)
                    reg_fstate <= START;
                else if (~(Go))
                    reg_fstate <= X_IDLE;
                // Inserting 'else' block to prevent latch inference
                else
                    reg_fstate <= X_IDLE;

                LDEN <= 1'b0;

                rstbicount <= 1'b0;

                ORDY <= 1'b0;

                SCEN <= 1'b1;

                SHEN <= 1'b0;

                bitcountEN <= 1'b0;

                SCLK <= 1'b1;
            end
            X_STOP: begin
                reg_fstate <= X_IDLE;

                LDEN <= 1'b0;

                bitcountEN <= 1'b0;

                SCLK <= 1'b0;
            end
            X_SHIFT: begin
                if ((bitcount[3:0] == 4'b1111))
                    reg_fstate <= X_STOP;
                else if ((bitcount[3:0] < 4'b1111))
                    reg_fstate <= X_SHIFT;
                // Inserting 'else' block to prevent latch inference
                else
                    reg_fstate <= X_SHIFT;

                LDEN <= 1'b0;

                if ((bitcount[3:0] < 4'b1111))
                    rstbicount <= 1'b0;
                else if ((bitcount[3:0] == 4'b1111))
                    rstbicount <= 1'b1;
                // Inserting 'else' block to prevent latch inference
                else
                    rstbicount <= 1'b0;

                ORDY <= 1'b0;

                SCEN <= 1'b0;

                SHEN <= 1'b1;

                bitcountEN <= 1'b1;

                SCLK <= 1'b0;
            end
            default: begin
                rstbicount <= 1'bx;
                bitcountEN <= 1'bx;
                SCLK <= 1'bx;
                SCEN <= 1'bx;
                ORDY <= 1'bx;
                LDEN <= 1'bx;
                SHEN <= 1'bx;
                $display ("Reach undefined state");
            end
        endcase
    end
endmodule // SPI_fsm
