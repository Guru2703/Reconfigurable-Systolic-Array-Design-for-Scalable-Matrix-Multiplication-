`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2025 18:49:29
// Design Name: 
// Module Name: SA_withcache
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


module SA_withcache;            
    reg clk,rst;                              
    reg [255:0] data_in;                                  
    reg [8:0] Waddr1,Waddr2,Waddr3,Waddr4,Waddr5,Waddr6,Waddr7,Waddr8;
    reg [7:0] r_en,w_en;                                   
//    wire [2:0] Completed;              
    wire [255:0] read_data;            
Coprocessor processor(              
clk,rst,
Waddr1,Waddr2,Waddr3,Waddr4,Waddr5,Waddr6,Waddr7,Waddr8,r_en,w_en,data_in,read_data );        
initial begin                     
        clk =0 ;                                            
        forever #5 clk=~clk ;         
end                               
reg [31:0] mema [0:3];             
reg [31:0] memb [0:3];  // 4 x 32-bit memory
initial begin                                                          
    $readmemb("matrix_B.mem", memb);      
    $readmemb("matrix_A.mem", mema); // Read hex values from file
end                                       
initial begin                     
        #5 rst =1;  
        #10 rst=0 ;w_en=8'b11111111 ; Waddr1=9'h1;Waddr2=9'h2;Waddr3=9'h3;Waddr4=9'h4;Waddr5=9'h5;Waddr6=9'h6;Waddr7=9'h7;Waddr8=9'h8;
        data_in = {memb[3],memb[2],memb[1],memb[0],mema[3],mema[2],mema[1],mema[0]};   
        //rd_i represents what address register need to store the upcoming address (1/2)
        //rd_vali = address to get (rd_i th register) input 
        //rd_val2 = address to get weight 
        //wd - to enable register to store address where the sub block need to write its output data 
        //wd_val - provides the address .
        r_en=8'b11111111;w_en=8'b11111111; 
        #250 $finish ;         
        
    end
    
endmodule
