`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2024 18:26:50
// Design Name: 
// Module Name: shiftcache
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

//No issue in storing verified.

 module sa_shift_register(
clk,rst,wr,data_in,shift,data_out
    );
    input clk,rst;
    input wr;
    input [31:0] data_in;
    input [3:0] shift;
    output [31:0] data_out ; 
    reg [7:0] store [15:0] ; 
    always @(posedge clk )begin
        if(rst)begin 
            store[0]<=0;
            store[1]<=0;
            store[2]<=0;
            store[3]<=0;
            store[4]<=0;
            store[5]<=0;
            store[6]<=0;
            store[7]<=0;
            store[8]<=0;
            store[9]<=0;
            store[10]<=0;
            store[11]<=0;
            store[12]<=0;
            store[13]<=0;
            store[14]<=0;
            store[15]<=0;
        end 
        if(wr)begin 
            store[0] <= data_in[7:0];
            store[1] <= data_in[15:8];
            store[2] <= data_in[23:16];
            store[3] <= data_in[31:24];
        end 
        if(shift[0])begin
            store[4]<=store[0];
            store[8]<=store[4];
            store[12]<=store[8];
        end
        if(shift[1])begin
            store[5]<=store[1];
            store[9]<=store[5];
            store[13]<=store[9];
        end
        if(shift[2])begin
            store[6]<=store[2];
            store[10]<=store[6];
            store[14]<=store[10];
        end
        if(shift[3])begin
            store[7]<=store[3];
            store[11]<=store[7];
            store[15]<=store[11];
        end
        $display("time:%t,data:%b,write:%b,shift:%b",$time,data_in,wr,shift);
        $display("stored:%b",{store[15],store[14],store[13],store[12]});
     end
     assign data_out = {store[15],store[14],store[13],store[12]};
    
endmodule
