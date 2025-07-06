`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2024 21:51:48
// Design Name: 
// Module Name: L2_cache
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

module SharedScratchpad#(parameter Data_width =32,Mem_size = 512,Addr_width = 9)
(clk,rst,raddr1,raddr2,raddr3,raddr4,raddr5,raddr6,raddr7,raddr8,
waddr1,waddr2,waddr3,waddr4,waddr5,waddr6,waddr7,waddr8,
r_en,w_en,
wdata1,wdata2,wdata3,wdata4,wdata5,wdata6,wdata7,wdata8
,rdata1,rdata2,rdata3,rdata4,rdata5,rdata6,rdata7,rdata8 );

//Inputs 

input clk ;
input rst ;
input [Addr_width-1:0]raddr1;
input [Addr_width-1:0]raddr2;
input [Addr_width-1:0]raddr3;
input [Addr_width-1:0]raddr4;
input [Addr_width-1:0]raddr5;
input [Addr_width-1:0]raddr6;
input [Addr_width-1:0]raddr7;
input [Addr_width-1:0]raddr8;

input [Addr_width-1:0]waddr1;
input [Addr_width-1:0]waddr2;
input [Addr_width-1:0]waddr3;
input [Addr_width-1:0]waddr4;
input [Addr_width-1:0]waddr5;
input [Addr_width-1:0]waddr6;
input [Addr_width-1:0]waddr7;
input [Addr_width-1:0]waddr8;
input [7:0] r_en;
wire r_en1,r_en2,r_en3,r_en4,r_en5,r_en6,r_en7,r_en8;
input [7:0] w_en;
wire w_en1,w_en2,w_en3,w_en4,w_en5,w_en6,w_en7,w_en8;
input [Data_width-1:0] wdata1,wdata2,wdata3,wdata4,wdata5,wdata6,wdata7,wdata8; 

//Outputs 
output reg [Data_width-1:0] rdata1,rdata2,rdata3,rdata4,rdata5,rdata6,rdata7,rdata8;


//Variables 
reg [Data_width-1:0] memory [Mem_size-1:0];
assign {r_en8,r_en7,r_en6,r_en5,r_en4,r_en3,r_en2,r_en1}=r_en;
assign {w_en8,w_en7,w_en6,w_en5,w_en4,w_en3,w_en2,w_en1}=w_en;
//Reading data 
always @(posedge clk)begin
if(rst)begin
    rdata1=0;
    rdata2=0;
    rdata3=0;
    rdata4=0;
    rdata5=0;
    rdata6=0;
    rdata7=0;
    rdata8=0; 
end
if(r_en1)
   rdata1 = memory[raddr1] ;
if(r_en2)
   rdata2 = memory[raddr2] ;
if(r_en3)
   rdata3 = memory[raddr3] ;
if(r_en4)
   rdata4 = memory[raddr4] ;
if(r_en5)
   rdata5 = memory[raddr5] ;
if(r_en6)
   rdata6 = memory[raddr6] ;
if(r_en7)
   rdata7 = memory[raddr7] ;
if(r_en8)
   rdata8 = memory[raddr8] ;

end

//Writing Data  
always @(negedge clk )begin
    $display("data from sys1:%h",memory[9'b000001001]);
    $display("data from sys2:%h",memory[9'b000001010]);
    $display("data from sys3:%h",memory[9'b000001011]);
    $display("data from sys4:%h",memory[9'b000001100]); 

    if(w_en1)
       memory[waddr1]=wdata1;
    if(w_en2)   
       memory[waddr2]=wdata2;
    if(w_en3)   
       memory[waddr3]=wdata3;
    if(w_en4)   
       memory[waddr4]=wdata4;
    if(w_en5)   
       memory[waddr5]=wdata5;
    if(w_en6)   
       memory[waddr6]=wdata6;
    if(w_en7)   
       memory[waddr7]=wdata7;
    if(w_en8)   
       memory[waddr8]=wdata8;
end

endmodule 