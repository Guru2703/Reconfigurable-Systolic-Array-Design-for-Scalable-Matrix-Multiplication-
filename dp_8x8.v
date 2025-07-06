`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.12.2024 13:27:23
// Design Name: 
// Module Name: dp_8x8
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


module Pe_scheduler8x8(
clk,rst,start,cp11,fc11,cp12,fc12,cp21,fc21,cp22,fc22,rst11,rst12,rst21,rst22
,Completed,rc11_8,rc12_8,rc21_8,rc22_8 );
    input clk,rst,start,cp11,fc11,cp12,fc12,cp21,fc21,cp22,fc22;
    output rst11,rst12,rst21,rst22;
    output [2:0] Completed;
    output rc11_8,rc12_8,rc21_8,rc22_8  ; 
    reg [2:0] completed;
    reg st11,st12,st21,st22;
reg [1:0] fcount11,fcount12,fcount21,fcount22;
reg [1:0] state;
parameter s0=0,s1=1,s2=2;
always @(posedge clk )begin
    if(rst) state<=s0;completed<=0;
    case(state)
        s0:state<=start?s1:s0;
        s1:state<=completed[2]==1?s2:s1;
    endcase
    $display("Started!");
end
always @(posedge clk)begin
    case(state)
        s0:begin
           st11<=0;st12<=0;st21<=0;st22<=0; fcount11<=0;
           fcount12<=0;
           fcount21<=0;
           fcount22<=0;
        end
        s1:begin
           // $display("fcount:%b",fcount11);
            case(fcount11)
                2'b00:st11<=1;
                2'b01:st11<=1;
                2'b10:st11<=0;
                2'b11:st11<=0;
            endcase
            //$display("start11:%b,rst11:%b",st11,rst11);
            if(cp11&fcount12[1]==0)begin
                st12<=1;
            end
            else begin
                st12<=0;
            end
            if(cp11&fcount21[1]==0)begin
                st21<=1;
            end
            else begin
                st21<=0;
            end
            if(cp12&fcount22[1]==0)begin
                st22<=1;
            end
            else begin
                st22<=0;
            end
            if(fc11&fcount11[1]!=1)begin
                fcount11<=fcount11+1;
                completed[2:0]<=completed[2:0]+3'b0001;
            end
            if(fc12&fcount12[1]!=1)begin
                fcount12<=fcount12+1;
                completed[2:0]<=completed[2:0]+3'b0001;
            end
            if(fc21&fcount21[1]!=1)begin
                 fcount21<=fcount21+1;
                 completed[2:0]<=completed[2:0]+3'b0001;
            end
            if(fc22&fcount22[1]!=1)begin
                 fcount22<=fcount22+1;
                 completed[2:0]<=completed[2:0]+3'b0001;
            end
            //$display("completed_status:%b ",completed);
        end
        s2:begin
            st11<=0;st12<=0;st21<=0;st22<=0;
        end
    endcase
end
    assign rst11= st11;
    assign rst12= st12;
    assign rst21= st21;
    assign rst22= st22;
    assign Completed= completed;
    assign rc11_8 = fcount11 ; 
    assign rc12_8 = fcount12 ;
    assign rc21_8 = fcount21;
    assign rc22_8 = fcount22;
endmodule
