`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2025 10:54:42
// Design Name: 
// Module Name: Instruction_Memory
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


module Instruction_Memory(
PC ,instr
    );
    input [9:0] PC ; 
    output [31:0] instr;
    reg [31:0] instr_mem[0:1023] ; 
    initial begin
        $readmemb("read_instr.mem",instr_mem) ; 
    end
    assign instr = instr_mem[PC] ; 
endmodule
