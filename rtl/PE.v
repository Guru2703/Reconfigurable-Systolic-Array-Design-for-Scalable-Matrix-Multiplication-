`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2024 13:45:17
// Design Name: 
// Module Name: PE
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


module PE(
clk,inp_n,inp_e,out_n,out_e,out_acc,en_share,en_store,rst,en_out
    );
    input clk;
    input rst,en_store,en_out,en_share;
    input [7:0] inp_n,inp_e;
    output [7:0] out_n,out_e;
    output [7:0] out_acc;
    reg [7:0] N,E;
//    wire [15:0] mul_result;
//    assign mul_result = inp_n * inp_e;
//    wire [7:0] scaled_mul = mul_result[13:6];

    reg [7:0] ACC;
  
    always @(posedge clk)begin
        //$display("North:%b,east:%b",inp_n,inp_e);
        if(rst)begin
            N<=0;
            E<=0;
            ACC<=0;
        end
        if(en_store)begin
            N<=inp_n;
            E<=inp_e;
            ACC<=ACC+inp_n*inp_e;
            $display("North:%b,East:%b",inp_n,inp_e) ; 
            $display("ACC:%b",ACC);
        end
    end
    assign out_n = en_share?N:0;
    assign out_e = en_share?E:0;
    assign out_acc = en_out?ACC:0;
endmodule
