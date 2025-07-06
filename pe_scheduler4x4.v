`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2024 22:37:14
// Design Name: 
// Module Name: pe_scheduler4x4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pe_scheduler4x4(
start,clk,rst,is4,sw,si,en_store,out_s,out_en,wr,finish_flag,can_pass,
counter_start,issyd
    );
    input rst,clk,start,is4;
    output reg [2:0] wr;
    output reg [4:0] sw,si,out_s,out_en;
    output reg [7:0] en_store;
    output reg finish_flag ;
    output reg can_pass; 
    output reg counter_start ;
    output reg issyd ; 
    reg [4:0] state;
    parameter s0=0,s1=1,s2=2,s3=3,s4=4,s5=5,s6=6,s7=7,s8=8,s9=9,s10=10;
    parameter s11=11,s12=12,s13=13,s14=14,s15=15,s16=16,s17=17,s18=18,s19=19,cs=20;
    always @(posedge clk)begin
     $display("time,%t,start:%b,statein4:%b,finished:%b",$time,start,state,finish_flag);
        if(rst) begin
         state<=s0; 
        end 
        case(state)
            s0:begin
                if(start) begin state<=cs;
                end 
                else state<=s0;
            end
            cs:state<=s1;
            s1:state<=s2;
            s2:state<=s3;
            s3:state<=s4;
            s4:state<=s5;
            s5:state<=s6;
            s6:state<=s7;
            s7:state<=s8;
            s8:state<=s9;
            s9:state<=s10;
            s10:state<=s11;
            s11:state<=s12;
            s12:state<=s13;
            s13:state<=s14;
            s14:state<=s15;
            s15:state<=s16;
            s16:state<=s17;
            s17:state<=s18;
            s18:state<=s19;
            s19:state<=s0;
        endcase
        $display("cs from pe scheduler :%b",counter_start) ; 
    end    
    always @(state)begin
   
        case(state)
            s0:begin
                can_pass<=0;
                finish_flag<=0; sw<=4'b0000;si<=4'b0000;en_store<=8'b00000000;wr<=0;out_en<=4'b0000;out_s<=4'b0000;
                issyd<=0 ; 
                counter_start<= start; 
                end
            cs: counter_start<=1; 
            s1:begin
                wr<=3'b011;
                counter_start <= 1 ; 
                end
            s2:begin
                sw<=4'b1111;si<=4'b1111;wr<=3'b011;
                counter_start <= 1; 
                end
            s3:begin
                can_pass<=1;
                sw<=4'b1111;si<=4'b1111;wr<=3'b011;
                counter_start <= 1; 
                end
            s4:begin    
                sw<=4'b1111;si<=4'b1111;wr<=3'b011;
                 counter_start <= 0; 
            end
            s5:begin
                sw<=4'b0001;si<=4'b0001;en_store<=8'b00000001;wr<=0;counter_start <=0 ; 
                end
            s6:begin
                sw<=4'b0011;si<=4'b0011;en_store<=8'b00000011;wr<=0;counter_start <=0 ; 
                end
            s7:begin
                
                sw<=4'b0111;si<=4'b0111;en_store<=8'b00000111;wr<=0;counter_start <= 0 ; 
                end
            s8:begin
                sw<=4'b1111;si<=4'b1111;en_store<=8'b00001111;wr<=0;counter_start <=0 ; 
                end
            s9:begin
                sw<=4'b1111;si<=4'b1111;en_store<=8'b00011110;wr<=is4?0:3'b000;counter_start <= 0 ; 
                end
            s10:begin    
                sw<=4'b1111;si<=4'b1111;en_store<=8'b00111100;wr<=is4?0:3'b000;counter_start <= 0 ; 
                end
            s11:begin    
                sw<=4'b1111;si<=4'b1111;en_store<=8'b01111000;wr<=is4?0:3'b000;counter_start <= 0 ; 
            end
            s12:begin   
                counter_start <= 0;  
                sw<=4'b1111;si<=4'b1111;en_store<=8'b11110000;wr<=3'b100;out_en<=4'b0001;out_s=4'b0000;
            end
            s13:begin    
                counter_start <=0 ; 
                sw<=4'b0000;si<=4'b0000;en_store<=8'b11100000;wr<=3'b100;out_en<=4'b0010;out_s<=4'b1111;
            end
            s14:begin    
                counter_start <=0 ; 
                sw<=4'b0000;si<=4'b0000;en_store<=8'b11000000;wr<=3'b100;out_en=4'b0100;out_s=4'b1111;
            end
            s15:begin   
                counter_start <=0 ;  
                sw<=4'b0000;si<=4'b0000;en_store<=8'b10000000;wr<=3'b100;out_en<=4'b1000;out_s<=4'b1111;
            end
            s16:begin
                counter_start <=1 ; 
                sw<=4'b0000;si<=4'b0000;en_store<=8'b00000000;wr<=0;out_en<=4'b0000;out_s<=4'b1111;issyd <=1;
            end
            s17:begin
                counter_start <=1 ; 
                sw<=4'b0000;si<=4'b0000;en_store<=8'b00000000;wr<=0;out_en<=4'b0000;out_s<=4'b1111;issyd <=1;
            end
            s18:begin
                counter_start <= 1 ; 
                finish_flag<= 1 ;sw<=4'b0000;si<=4'b0000;en_store<=8'b00000000;wr<=0;out_en<=4'b0000;out_s<=4'b1111;issyd <=1;
            end
            s19:begin
                counter_start <=1 ; 
                finish_flag<= 0 ;sw<=4'b0000;si<=4'b0000;en_store<=8'b00000000;wr<=0;out_en<=4'b0000;out_s<=4'b0000;issyd <=1 ; 
            end
        endcase
    end
//    assign counter_start = !(state[2]|state[3])&start ? 1:0 ;
endmodule
/*
00000
00001
00010
00011
10000
10001
10010
10011
*/
