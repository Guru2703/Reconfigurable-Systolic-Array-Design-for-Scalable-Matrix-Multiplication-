`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2025 21:46:41
// Design Name: 
// Module Name: ctrl_unit_main
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


module ctrl_unit_main(
    instr,rd_i,rd_w,wd,is4,rst,start
    );
    input [31:0] instr ;
    output [1:0] rd_i,rd_w;
    output wd,is4,rst; 
    output [3:0] start; 
    reg [10:0] ctrl_sig ; 
    always @(*)begin
        case(instr[31:29])
            3'b000:ctrl_sig <= {instr[26:25],2'b0,1'b0,1'b0,4'b0,1'b0} ; 
            3'b001:ctrl_sig <= {2'b0,instr[26:25],1'b0,1'b0,4'b0,1'b0} ;
            3'b010:ctrl_sig <= {2'b0,2'b0,1'b0,instr[24],instr[23:20],1'b0} ;
            3'b011:ctrl_sig <= {2'b0,2'b0,1'b1,1'b0,4'b0,1'b0} ;
            3'b100:ctrl_sig <= {2'b0,2'b0,1'b0,1'b0,4'b0,1'b1} ;
            default : ctrl_sig <= {2'b0,2'b0,1'b0,1'b0,4'b0,1'b0} ;
         endcase
    end
    assign {rd_i, rd_w, wd, is4, start, rst} = ctrl_sig;
endmodule
