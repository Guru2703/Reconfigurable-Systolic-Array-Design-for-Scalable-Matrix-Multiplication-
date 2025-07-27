`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2024 23:08:48
// Design Name: 
// Module Name: Coprocessor
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

module Coprocessor(
    clk, rst,
    Waddr1, Waddr2, Waddr3, Waddr4, Waddr5, Waddr6, Waddr7, Waddr8,
    r_en, w_en, data_in, read_data
);
    input clk, rst;
    input [255:0] data_in; // 8 words of 32-bit each packed as a single input
    input [8:0] Waddr1, Waddr2, Waddr3, Waddr4, Waddr5, Waddr6, Waddr7, Waddr8; // write addresses for 8 ports
    input [7:0] r_en, w_en; // read and write enable lines
    output [255:0] read_data; // combined read output

    // Program counter for instruction memory access
    reg [9:0] PC;

    // Intermediate control/data wires for block selection
    wire [2:0] Completed;
    wire [1:0] rd_i11, rd_w11, rd_i12, rd_w12, rd_i21, rd_w21, rd_i22, rd_w22;
    wire wd11, wd12, wd21, wd22;

    // Data lines for 8 parallel inputs and outputs
    wire [31:0] wdata1, wdata2, wdata3, wdata4, wdata5, wdata6, wdata7, wdata8;
    wire [31:0] rdata1, rdata2, rdata3, rdata4, rdata5, rdata6, rdata7, rdata8;

    // Address and control buses for PE and scratchpad access
    wire [8:0] rd_vali11, rd_vali12, rd_vali21, rd_vali22;
    wire [8:0] rd_valw11, rd_valw12, rd_valw21, rd_valw22;
    wire [8:0] wd_val11, wd_val12, wd_val21, wd_val22;

    wire [127:0] out_tot;

    // Internal scratchpad control and data routing signals
    wire [3:0] sw11, si11, out_s11, out_en11;
    wire [3:0] sw12, si12, out_s12, out_en12;
    wire [3:0] sw21, si21, out_s21, out_en21;
    wire [3:0] sw22, si22, out_s22, out_en22;

    wire [7:0] en_store11, en_store12, en_store21, en_store22;
    wire [3:0] wr11, wr12, wr21, wr22;
    wire counter_start11, counter_start12, counter_start21, counter_start22;
    wire [8:0] get_wadd11, get_wadd12, get_wadd21, get_wadd22;
    wire issyd11, issyd12, issyd21, issyd22;

    wire [8:0] waddr1, waddr2, waddr3, waddr4, waddr5, waddr6, waddr7, waddr8;
    wire [8:0] get_addi11, get_addi12, get_addi21, get_addi22;
    wire [8:0] get_addw11, get_addw12, get_addw21, get_addw22;

    // Read back combined 8-word data
    wire [255:0] data_out;

    wire er11, ec11, er12, ec12, er21, ec21, er22, ec22;
    wire r_ctrl11, r_ctrl12, r_ctrl21, r_ctrl22;

    // Flattened write enable bus for systolic array
    wire [11:0] wr = {
        wr22[2], wr21[2], wr12[2], wr11[2],
        wr22[1], wr21[1], wr12[1], wr11[1],
        wr22[0], wr21[0], wr12[0], wr11[0]
    };

    wire [31:0] instr; // Current instruction
    wire [1:0] block_id; // Block being targeted
    wire [8:0] addr; // Operand address
    wire [1:0] rd_i, rd_w;
    wire wd, is4;
    wire [3:0] start;
    wire rst11, rst12, rst21, rst22;

    // Muxing between external and internal write addresses
    assign waddr1 = issyd11 ? get_wadd11 : Waddr1;
    assign waddr2 = issyd12 ? get_wadd12 : Waddr2;
    assign waddr3 = issyd21 ? get_wadd21 : Waddr3;
    assign waddr4 = issyd22 ? get_wadd22 : Waddr4;
    assign waddr5 = Waddr5;
    assign waddr6 = Waddr6;
    assign waddr7 = Waddr7;
    assign waddr8 = Waddr8;

    // Muxing write data from either input or output of systolic array
    assign wdata1 = issyd11 ? out_tot[31:0]    : data_in[31:0];
    assign wdata2 = issyd12 ? out_tot[63:32]   : data_in[63:32];
    assign wdata3 = issyd21 ? out_tot[95:64]   : data_in[95:64];
    assign wdata4 = issyd22 ? out_tot[127:96]  : data_in[127:96];
    assign wdata5 = data_in[159:128];
    assign wdata6 = data_in[191:160];
    assign wdata7 = data_in[223:192];
    assign wdata8 = data_in[255:224];

    assign data_out = {rdata8, rdata7, rdata6, rdata5, rdata4, rdata3, rdata2, rdata1};
    assign read_data = data_out;

    // Program counter and debug displays
    always @(posedge clk) begin
        if (rst)
            PC <= 0;
        else
            PC <= PC + 1;
        // $display("PC:%b, Instr:%b,Reading_addr:%b", PC, instr, addr);
        // $display("rdi:%b,rdw:%b,wd:%b,rst_ctlr:%b", rd_i, rd_w, wd, rst_ctrl);
        // $display("raddr1:%b,raddr2:%b,raddr3:%b,raddr4:%b", rd_vali11, rd_vali12, rd_vali21, rd_vali22);
        // $display("get_addi11:%h,get_addw11:%h", get_addi11, get_addw11);
        // $display("waddr1:%b",waddr1);
        // $display("issyd:%b",issyd11);
        // $display("data_sended:%b",wdata1);
    end

    // Submodule instantiations
    SharedScratchpad mem(
        clk, rst,
        get_addi11, get_addi12, get_addi21, get_addi22,
        get_addw11, get_addw12, get_addw21, get_addw22,
        waddr1, waddr2, waddr3, waddr4, waddr5, waddr6, waddr7, waddr8,
        r_en, w_en,
        wdata1, wdata2, wdata3, wdata4, wdata5, wdata6, wdata7, wdata8,
        rdata1, rdata2, rdata3, rdata4, rdata5, rdata6, rdata7, rdata8
    );

    reconfigurable_scheduler scheduler(
        block_id, clk, rst, is4, start, Completed,
        sw11, si11, out_s11, out_en11,
        sw12, si12, out_s12, out_en12,
        sw21, si21, out_s21, out_en21,
        sw22, si22, out_s22, out_en22,
        en_store11, en_store12, en_store21, en_store22,
        wr11, wr12, wr21, wr22,
        er11, ec11, er12, ec12, er21, ec21, er22, ec22,
        counter_start11, counter_start12, counter_start21, counter_start22,
        r_ctrl11, r_ctrl12, r_ctrl21, r_ctrl22,
        issyd11, issyd12, issyd21, issyd22
    );

    Instruction_Memory instr_mem(
        PC, instr
    );

    ctrl_unit_main controller(
        instr, rd_i, rd_w, wd, is4, rst_ctrl, start
    );

    // Instruction field decoding
    assign addr = instr[8:0];
    assign block_id = instr[28:27];

    // Conditional operand routing to corresponding blocks
    assign rd_vali11 = (block_id == 2'b00) ? addr : 0;
    assign rd_vali12 = (block_id == 2'b01) ? addr : 0;
    assign rd_vali21 = (block_id == 2'b10) ? addr : 0;
    assign rd_vali22 = (block_id == 2'b11) ? addr : 0;

    assign rd_valw11 = (block_id == 2'b00) ? addr : 0;
    assign rd_valw12 = (block_id == 2'b01) ? addr : 0;
    assign rd_valw21 = (block_id == 2'b10) ? addr : 0;
    assign rd_valw22 = (block_id == 2'b11) ? addr : 0;

    assign wd_val11 = (block_id == 2'b00) ? addr : 0;
    assign wd_val12 = (block_id == 2'b01) ? addr : 0;
    assign wd_val21 = (block_id == 2'b10) ? addr : 0;
    assign wd_val22 = (block_id == 2'b11) ? addr : 0;

    assign rd_i11 = (block_id == 2'b00) ? rd_i : 0;
    assign rd_i12 = (block_id == 2'b01) ? rd_i : 0;
    assign rd_i21 = (block_id == 2'b10) ? rd_i : 0;
    assign rd_i22 = (block_id == 2'b11) ? rd_i : 0;

    assign rd_w11 = (block_id == 2'b00) ? rd_w : 0;
    assign rd_w12 = (block_id == 2'b01) ? rd_w : 0;
    assign rd_w21 = (block_id == 2'b10) ? rd_w : 0;
    assign rd_w22 = (block_id == 2'b11) ? rd_w : 0;

    assign wd11 = (block_id == 2'b00) ? wd : 0;
    assign wd12 = (block_id == 2'b01) ? wd : 0;
    assign wd21 = (block_id == 2'b10) ? wd : 0;
    assign wd22 = (block_id == 2'b11) ? wd : 0;

    assign rst11 = (block_id == 2'b00) ? rst_ctrl : 0;
    assign rst12 = (block_id == 2'b01) ? rst_ctrl : 0;
    assign rst21 = (block_id == 2'b10) ? rst_ctrl : 0;
    assign rst22 = (block_id == 2'b11) ? rst_ctrl : 0;

    // Instantiating the main systolic array
    SA systollic_array(
        r_ctrl11, r_ctrl12, r_ctrl21, r_ctrl22,
        rd_i11, rd_w11, counter_start11,
        rd_i12, rd_w12, counter_start12,
        rd_i21, rd_w21, counter_start21,
        rd_i22, rd_w22, counter_start22,
        wd11, wd12, wd21, wd22,
        rd_vali11, rd_vali12, rd_vali21, rd_vali22,
        rd_valw11, rd_valw12, rd_valw21, rd_valw22,
        wd_val11, wd_val12, wd_val21, wd_val22,
        clk, rst11, rst12, rst21, rst22,
        data_out, wr,
        si11, si12, si21, si22,
        sw11, sw12, sw21, sw22,
        er11, ec11, er12, ec12, er21, ec21, er22, ec22,
        out_tot,
        en_store11, en_store12, en_store21, en_store22,
        out_en11, out_en12, out_en21, out_en22,
        out_s11, out_s12, out_s21, out_s22,
        get_addi11, get_addi12, get_addi21, get_addi22,
        get_addw11, get_addw12, get_addw21, get_addw22,
        get_wadd11, get_wadd12, get_wadd21, get_wadd22
    );
endmodule






// module Coprocessor(
// clk,rst,
// Waddr1,Waddr2,Waddr3,Waddr4,Waddr5,Waddr6,Waddr7,Waddr8,
// r_en,w_en,data_in,read_data  );
//     input clk,rst;
//     input [255:0] data_in;
//     input [8:0] Waddr1,Waddr2,Waddr3,Waddr4,Waddr5,Waddr6,Waddr7,Waddr8; 
//     input [7:0] r_en,w_en; 
    
//     wire [2:0] Completed;
//     output [255:0] read_data; 
//     reg [9:0] PC ;
//     wire [1:0] rd_i11,rd_w11,rd_i12,rd_w12,rd_i21,rd_w21,rd_i22,rd_w22 ;
//     wire  wd11,wd12,wd21,wd22;
//     wire [31:0] wdata1,wdata2,wdata3,wdata4,wdata5,wdata6,wdata7,wdata8
//     ,rdata1,rdata2,rdata3,rdata4,rdata5,rdata6,rdata7,rdata8; 
//     wire [8:0] rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ,rd_valw11 ,rd_valw12 ,rd_valw21 ,rd_valw22 ,wd_val11,wd_val12,wd_val21,wd_val22 ;
//     wire [127:0] out_tot;
//     wire [3:0] sw11,si11,out_s11,out_en11;
//     wire [3:0] sw12,si12,out_s12,out_en12;
//     wire [3:0] sw21,si21,out_s21,out_en21;
//     wire [3:0] sw22,si22,out_s22,out_en22;
//     wire [7:0] en_store11,en_store12,en_store21,en_store22;
//     wire [3:0] wr11,wr12,wr21,wr22;
//     wire counter_start11,counter_start12,counter_start21,counter_start22;
//     wire [8:0] get_wadd11,get_wadd12,get_wadd21,get_wadd22;
//     wire issyd11,issyd12,issyd21,issyd22; 
//     wire [8:0] waddr1,waddr2,waddr3,waddr4,waddr5,waddr6,waddr7,waddr8;
//     wire [8:0]  get_addi11 , get_addi12 ,get_addi21 ,get_addi22,
//     get_addw11 , get_addw12 ,get_addw21 ,get_addw22 ;
//     wire [255:0] data_out;
//     wire er11,ec11,er12,ec12,er21,ec21,er22,ec22;
//     wire r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22;
//     wire [11:0] wr={wr22[2],wr21[2],wr12[2],wr11[2],wr22[1],wr21[1],wr12[1],wr11[1],wr22[0],wr21[0],wr12[0],wr11[0]};
//     wire [31:0] instr ;
//     wire [1:0] block_id ; 
//     wire [8:0] addr ; 
//     wire [1:0] rd_i,rd_w;
//     wire wd,is4; 
//     wire [3:0] start; 
//     wire rst11,rst12,rst21,rst22;
    
//     assign waddr1= issyd11? get_wadd11:Waddr1 ; 
//     assign waddr2= issyd12? get_wadd12:Waddr2 ; 
//     assign waddr3= issyd21? get_wadd21:Waddr3 ; 
//     assign waddr4= issyd22? get_wadd22:Waddr4 ; 
//     assign waddr5 = Waddr5 ; 
//     assign waddr6 = Waddr6 ; 
//     assign waddr7 = Waddr7 ; 
//     assign waddr8 = Waddr8 ; 
//     assign wdata1 = issyd11? out_tot[31:0]    : data_in[31:0];
//     assign wdata2 = issyd12 ? out_tot[63:32]   : data_in[63:32];
//     assign wdata3 = issyd21 ? out_tot[95:64]   : data_in[95:64];
//     assign wdata4 = issyd22 ? out_tot[127:96]  : data_in[127:96];
//     assign wdata5 =  data_in[159:128];
//     assign wdata6 =  data_in[191:160];
//     assign wdata7 =  data_in[223:192];
//     assign wdata8 =  data_in[255:224];
//     assign data_out={rdata8,rdata7,rdata6,rdata5,rdata4,rdata3,rdata2,rdata1} ; 
//     assign read_data = data_out ;
    
//     always @(posedge clk)begin
//        if (rst)
//         PC <= 0;
//        else
//         PC <= PC + 1;
        
//         $display("PC:%b, Instr:%b,Reading_addr:%b",PC,instr,addr) ;
//         $display("rdi:%b,rdw:%b,wd:%b,rst_ctlr:%b",rd_i,rd_w,wd,rst_ctrl) ;
//         $display("raddr1:%b,raddr2:%b,raddr3:%b,raddr4:%b",rd_vali11,rd_vali12,rd_vali21,rd_vali22);
//         $display("get_addi11:%h,get_addw11:%h",get_addi11,get_addw11) ;
// //        $display("waddr1:%b",waddr1);
// //        $display("issyd:%b",issyd11);
// //        $display("data_sended:%b",wdata1) ;
//     end
  
  
//     SharedScratchpad mem(clk,rst,get_addi11,get_addi12,get_addi21,get_addi22,get_addw11,get_addw12,get_addw21,get_addw22,
//     waddr1,waddr2,waddr3,waddr4,waddr5,waddr6,waddr7,waddr8,
//     r_en,w_en,
//     wdata1,wdata2,wdata3,wdata4,wdata5,wdata6,wdata7,wdata8
//     ,rdata1,rdata2,rdata3,rdata4,rdata5,rdata6,rdata7,rdata8 );


//     reconfigurable_scheduler scheduler(
//     block_id ,clk,rst,is4,start,Completed,
//     sw11,si11,out_s11,out_en11,sw12,si12,out_s12,out_en12,
//     sw21,si21,out_s21,out_en21,sw22,si22,out_s22,out_en22,
//     en_store11,en_store12,
//     en_store21,en_store22,
//     wr11,wr12,
//     wr21,wr22,er11,ec11,er12,ec12,er21,ec21,er22,ec22,
//     counter_start11,counter_start12,counter_start21,counter_start22,
//     r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22,
//     issyd11,issyd12,issyd21,issyd22
//     );
    
//     Instruction_Memory instr_mem(
//     PC ,instr
//     );
    
//     ctrl_unit_main controller(
//     instr,rd_i,rd_w,wd,is4,rst_ctrl,start
//     );
     
//     assign addr = instr[8:0];
//     assign block_id = instr[28:27] ;
    
//     assign rd_vali11 = (block_id == 2'b00) ? addr : 0;
//     assign rd_vali12 = (block_id == 2'b01) ? addr : 0;
//     assign rd_vali21 = (block_id == 2'b10) ? addr : 0;
//     assign rd_vali22 = (block_id == 2'b11) ? addr : 0;
    
//     assign rd_valw11 = (block_id == 2'b00) ? addr : 0;
//     assign rd_valw12 = (block_id == 2'b01) ? addr : 0;
//     assign rd_valw21 = (block_id == 2'b10) ? addr : 0;
//     assign rd_valw22 = (block_id == 2'b11) ? addr : 0;
    
//     assign wd_val11 = (block_id == 2'b00) ? addr : 0;
//     assign wd_val12 = (block_id == 2'b01) ? addr : 0;
//     assign wd_val21 = (block_id == 2'b10) ? addr : 0;
//     assign wd_val22 = (block_id == 2'b11) ? addr : 0;
    
//     assign rd_i11 = (block_id == 2'b00) ? rd_i : 0;
//     assign rd_i12 = (block_id == 2'b01) ? rd_i : 0;
//     assign rd_i21 = (block_id == 2'b10) ? rd_i : 0;
//     assign rd_i22 = (block_id == 2'b11) ? rd_i : 0;

//     assign rd_w11 = (block_id == 2'b00) ? rd_w : 0;
//     assign rd_w12 = (block_id == 2'b01) ? rd_w : 0;
//     assign rd_w21 = (block_id == 2'b10) ? rd_w : 0;
//     assign rd_w22 = (block_id == 2'b11) ? rd_w : 0;   
    
//     assign wd11 = (block_id == 2'b00) ? wd : 0;
//     assign wd12 = (block_id == 2'b01) ? wd : 0;
//     assign wd21 = (block_id == 2'b10) ? wd : 0;
//     assign wd22 = (block_id == 2'b11) ? wd : 0;
    
//     assign rst11 = (block_id == 2'b00) ? rst_ctrl : 0;
//     assign rst12 = (block_id == 2'b01) ? rst_ctrl : 0;
//     assign rst21 = (block_id == 2'b10) ? rst_ctrl : 0;
//     assign rst22 = (block_id == 2'b11) ? rst_ctrl : 0;
    
//     SA systollic_array(r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22,rd_i11 ,rd_w11 ,counter_start11 ,rd_i12 ,rd_w12 ,counter_start12 ,rd_i21 ,rd_w21 ,counter_start21 ,rd_i22 ,rd_w22 ,counter_start22,
//     wd11,wd12,wd21,wd22 
// ,rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ,rd_valw11 ,rd_valw12 ,rd_valw21 , rd_valw22 ,
//     wd_val11,wd_val12,wd_val21,wd_val22
//     ,clk,rst11,rst12,rst21,rst22,data_out,wr,si11,si12,si21,si22,sw11,sw12,sw21,sw22,er11,ec11,er12,ec12,er21,ec21,er22,ec22,out_tot,
//         en_store11,en_store12,en_store21,en_store22,out_en11,out_en12,out_en21,out_en22,
//         out_s11,out_s12,out_s21,out_s22,
//  get_addi11 , get_addi12 ,get_addi21 ,get_addi22,
//  get_addw11 , get_addw12 ,get_addw21 ,get_addw22,
//  get_wadd11,get_wadd12,get_wadd21,get_wadd22);
// endmodule
