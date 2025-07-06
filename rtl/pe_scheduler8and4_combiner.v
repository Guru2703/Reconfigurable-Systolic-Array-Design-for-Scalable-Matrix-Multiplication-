`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2025 12:35:27
// Design Name: 
// Module Name: pe_scheduler8and4_combiner
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


module reconfigurable_scheduler(
block_id,clk,rst,is4,start,Completed,
sw11,si11,out_s11,out_en11,sw12,si12,out_s12,out_en12,
sw21,si21,out_s21,out_en21,sw22,si22,out_s22,out_en22,
en_store11,en_store12,
en_store21,en_store22,
wr11,wr12,
wr21,wr22,er11,ec11,er12,ec12,er21,ec21,er22,ec22,
counter_start11,counter_start12,counter_start21,counter_start22,
r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22,
issyd11,issyd12,issyd21,issyd22
);
wire rst11,rst12,rst21,rst22;
input [1:0] block_id;
input clk,rst,is4;
input [3:0] start;
output [2:0] Completed;
output [3:0] sw11,si11,out_s11,out_en11,sw12,si12,out_s12,out_en12;
output [3:0] sw21,si21,out_s21,out_en21,sw22,si22,out_s22,out_en22;
output [7:0] en_store11,en_store12;
output [7:0] en_store21,en_store22;
output [2:0] wr11,wr12;
output [2:0] wr21,wr22;
output reg er11,ec11,er12,ec12,er21,ec21,er22,ec22;
output counter_start11,counter_start12,counter_start21,counter_start22;
output r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22;
output issyd11,issyd12,issyd21,issyd22 ; 
wire fc11,cp11,fc12,cp12;
wire fc21,cp21,fc22,cp22;
wire rc11_8,rc12_8,rc21_8,rc22_8 ; 

always @(posedge clk)begin
    if (is4) begin
    if (block_id == 2'b10) er11 <= start[2];
    if (block_id == 2'b01) ec11 <= start[1];
    if (block_id == 2'b11) begin
        ec21 <= start[3];
        er12 <= start[3];
    end
end
    else begin
        if(start[0]) begin
            er11<= 0;
            ec11<= 0;
            ec21<= 0;
            er12<= 0;
        end
    end
    $display("er11:%b,ec11:%b,er12:%b,ec21:%b",er11,ec11,er12,ec21) ; 
end

assign r_ctrl11 = is4?0:rc11_8; 
assign r_ctrl12 = is4?0:rc12_8; 
assign r_ctrl21 = is4?0:rc21_8; 
assign r_ctrl22 = is4?0:rc22_8; 
Pe_scheduler8x8 Main(
clk,rst,is4?0:start,cp11,fc11,cp12,fc12,cp21,fc21,cp22,fc22,rst11,rst12,rst21,rst22
,Completed,rc11_8,rc12_8,rc21_8,rc22_8);

pe_scheduler4x4 T11(
is4?start[0]:rst11,clk,rst,is4,sw11,si11,en_store11,out_s11,out_en11,wr11,fc11,cp11,
counter_start11,issyd11
    );
pe_scheduler4x4 T12(
is4?start[1]:rst12,clk,rst,is4,sw12,si12,en_store12,out_s12,out_en12,wr12,fc12,cp12,
counter_start12,issyd12
   );
pe_scheduler4x4 T21(
is4?start[2]:rst21,clk,rst,is4,sw21,si21,en_store21,out_s21,out_en21,wr21,fc21,cp21,
counter_start21,issyd21
    );
pe_scheduler4x4 T22(
is4?start[3]:rst22,clk,rst,is4,sw22,si22,en_store22,out_s22,out_en22,wr22,fc22,cp22,
counter_start22,issyd22
   );
endmodule
