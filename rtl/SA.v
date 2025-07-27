`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2024 23:10:46
// Design Name: 
// Module Name: SA
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

module SA(
    // Control signals for each sub-block
    r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22,
    
    // Read index and count control
    rd_i11 ,rd_w11 ,count_start11 ,rd_i12 ,rd_w12 ,count_start12 ,
    rd_i21 ,rd_w21 ,count_start21 ,rd_i22 ,rd_w22 ,count_start22 ,
    
    // Write enable signals for output
    wd11,wd12,wd21,wd22,
    
    // Read and write address inputs for input and weight matrices
    rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ,
    rd_valw11 ,rd_valw12 ,rd_valw21 , rd_valw22 ,
    wd_val11,wd_val12,wd_val21,wd_val22,
    
    // Clock and reset signals for each block
    clk,rst11,rst12,rst21,rst22,
    
    // Data input and write signal (for 4x4 blocks, total 256 bits)
    data_in,wr,
    
    // Shift-in control for input and weight shift registers
    si11,si12,si21,si22,
    sw11,sw12,sw21,sw22,
    
    // Data dependencies from neighboring sub-blocks
    er11,ec11,er12,ec12,er21,ec21,er22,ec22,
    
    // Output enabling and shift-out control for output shift registers
    out_tot,
    en_store11,en_store12,en_store21,en_store22,
    out_en11,out_en12,out_en21,out_en22,
    out_s11,out_s12,out_s21,out_s22,
    
    // Output address tracing (for external cache or logs)
    get_addi11 , get_addi12 ,get_addi21 ,get_addi22,
    get_addw11 , get_addw12 ,get_addw21 ,get_addw22,
    get_wadd11,get_wadd12,get_wadd21,get_wadd22
); 

    // Input declarations
    input clk,rst11,rst12,rst21,rst22;
    input r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22;
    input [255:0] data_in;
    input [11:0] wr;
    input [7:0] en_store11,en_store12,en_store21,en_store22;
    input er11,ec11,er12,ec12,er21,ec21,er22,ec22;
    input [3:0] si11,si12,si21,si22,sw11,sw12,sw21,sw22;
    input [3:0] out_en11,out_en12,out_en21,out_en22,out_s11,out_s12,out_s21,out_s22;
    input [1:0] rd_i11 ,rd_w11,rd_i12 ,rd_w12,rd_i21 ,rd_w21,rd_i22 ,rd_w22;
    input wd11,wd12,wd21,wd22 ; 
    input count_start11 ,count_start12 ,count_start21 ,count_start22 ;
    input [8:0] rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ;
    input [8:0] rd_valw11 ,rd_valw12 ,rd_valw21 , rd_valw22 ;
    input [8:0] wd_val11,wd_val12,wd_val21,wd_val22 ;

    // Output declarations
    output [127:0] out_tot;
    output [8:0] get_addi11 , get_addi12 ,get_addi21 ,get_addi22 ; 
    output [8:0] get_addw11 , get_addw12 ,get_addw21 ,get_addw22 ; 
    output [8:0] get_wadd11,get_wadd12,get_wadd21,get_wadd22;

    // Output from each sub-block
    wire [31:0] out11,out12,out21,out22;

    // East and North wires for interconnections
    wire [31:0] n11,e11,n12,n22,n21,e22,e21,e12;

    // Unique ID for each SM block
    wire [2:0] s11=3'b001,s12=3'b010,s21=3'b011,s22=3'b100;

    // Shift register outputs
    wire [31:0] N11,N12,N21,N22,E11,E12,E21,E22;

    // Split write control signal into individual bits
    wire wr1,wr2,wr3,wr4,wr5,wr6,wr7,wr8,wr9,wr10,wr11,wr12;
    assign {wr12,wr11,wr10,wr9,wr8,wr7,wr6,wr5,wr4,wr3,wr2,wr1}= wr ;

    // Instantiate input shift registers (4 blocks)
    sa_shift_register i11(clk,rst11,wr1,data_in[31:0],si11,E11);
    sa_shift_register i12(clk,rst12,wr2,data_in[63:32],si12,E12);
    sa_shift_register i21(clk,rst21,wr3,data_in[95:64],si21,E21);
    sa_shift_register i22(clk,rst22,wr4,data_in[127:96],si22,E22);

    // Instantiate weight shift registers (4 blocks)
    sa_shift_register w11(clk,rst11,wr5,data_in[159:128],sw11,N11);
    sa_shift_register w12(clk,rst12,wr6,data_in[191:160],sw12,N12);
    sa_shift_register w21(clk,rst21,wr7,data_in[223:192],sw21,N21);
    sa_shift_register w22(clk,rst22,wr8,data_in[255:224],sw22,N22);

    // Instantiate output shift registers (4 blocks)
    sa_shift_register o11(clk,rst11,wr9,out11,out_s11,out_tot[31:0]);
    sa_shift_register o12(clk,rst12,wr10,out12,out_s12,out_tot[63:32]);
    sa_shift_register o21(clk,rst21,wr11,out21,out_s21,out_tot[95:64]);
    sa_shift_register o22(clk,rst22,wr12,out22,out_s22,out_tot[127:96]);

    // Debugging: Print some connectivity flags
    always @(posedge clk) begin
        $display("er11:%b,ec11:%b,er12:%b,ec21:%b",er11,ec11,er12,ec21); 
    end

    // Instantiate systolic modules (SMs)
    // Each SM handles local computation, and shares East/North data with neighbors
    SM sm11(
        r_ctrl11,rd_i11,rd_w11,wd11,wd_val11,count_start11,rd_vali11,rd_valw11,
        clk,rst11,
        N11,E11,
        e11,n11,
        out11,
        en_store11[6:0],en_store11[7:1],
        out_en11,
        s11,get_addi11,get_addw11,get_wadd11
    );

    SM sm12(
        r_ctrl12,rd_i12,rd_w12,wd12,wd_val12,count_start12,rd_vali12,rd_valw12,
        clk,rst12,
        N12,ec11?E12:e11, // east input: either E12 or from left neighbor (e11)
        e12,n12,
        out12,
        en_store12[6:0],en_store12[7:1],
        out_en12,
        s12,get_addi12,get_addw12,get_wadd12
    );

    SM sm21(
        r_ctrl21,rd_i21,rd_w21,wd21,wd_val21,count_start21,rd_vali21,rd_valw21,
        clk,rst21,
        er11?N21:n11, // north input: either N21 or from top neighbor (n11)
        E21,
        e21,n21,
        out21,
        en_store21[6:0],en_store21[7:1],
        out_en21,
        s21,get_addi21,get_addw21,get_wadd21
    );

    SM sm22(
        r_ctrl22,rd_i22,rd_w22,wd22,wd_val22,count_start22,rd_vali22,rd_valw22,
        clk,rst22,
        er12?N22:n12, // north input: either N22 or from top neighbor (n12)
        ec21?E22:e21, // east input: either E22 or from left neighbor (e21)
        e22,n22,
        out22,
        en_store22[6:0],en_store22[7:1],
        out_en22,
        s22,get_addi22,get_addw22,get_wadd22
    );

  

endmodule



// module SA(
// r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22,
// rd_i11 ,rd_w11 ,count_start11 ,rd_i12 ,rd_w12 ,count_start12 ,rd_i21 ,rd_w21 ,count_start21 ,rd_i22 ,rd_w22 ,count_start22 ,
// wd11,wd12,wd21,wd22
// ,rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ,rd_valw11 ,rd_valw12 ,rd_valw21 , rd_valw22 ,
// wd_val11,wd_val12,wd_val21,wd_val22
// ,clk,rst11,rst12,rst21,rst22,
// data_in,wr,si11,si12,si21,si22,sw11,sw12,sw21,sw22,er11,ec11,er12,ec12,er21,ec21,er22,ec22,out_tot,
// en_store11,en_store12,en_store21,en_store22,out_en11,out_en12,out_en21,out_en22
// ,out_s11,out_s12,out_s21,out_s22,
//  get_addi11 , get_addi12 ,get_addi21 ,get_addi22,
//  get_addw11 , get_addw12 ,get_addw21 ,get_addw22,
//  get_wadd11,get_wadd12,get_wadd21,get_wadd22
//     ); 
//     input clk,rst11,rst12,rst21,rst22;
//     input r_ctrl11,r_ctrl12,r_ctrl21,r_ctrl22;
//     input [255:0] data_in;
//     input [11:0] wr;
//     input [7:0] en_store11,en_store12,en_store21,en_store22;
//     input er11,ec11,er12,ec12,er21,ec21,er22,ec22;
//     input [3:0] si11,si12,si21,si22,sw11,sw12,sw21,sw22,out_en11,out_en12,out_en21,out_en22,out_s11,out_s12,out_s21,out_s22;
//     input [1:0] rd_i11 ,rd_w11,rd_i12 ,rd_w12,rd_i21 ,rd_w21,rd_i22 ,rd_w22;
//     input wd11,wd12,wd21,wd22 ; 
//     input count_start11 ,count_start12 ,count_start21 ,count_start22 ;
//     input [8:0] rd_vali11 ,rd_vali12 ,rd_vali21 , rd_vali22 ,rd_valw11 ,rd_valw12 ,rd_valw21 , rd_valw22 ;
//     input [8:0] wd_val11,wd_val12,wd_val21,wd_val22 ; 
//     output [127:0] out_tot;
//     output [8:0] get_addi11 , get_addi12 ,get_addi21 ,get_addi22 ; 
//     output [8:0] get_addw11 , get_addw12 ,get_addw21 ,get_addw22 ; 
//     output [8:0] get_wadd11,get_wadd12,get_wadd21,get_wadd22;
//     //clk,rst,wr,data_in,shift,data_out
//     wire [31:0] out11,out12,out21,out22;
//     wire [31:0] n11,e11,n12,n22,n21,e22,e21,e12; 
//     wire [2:0] s11=3'b001,s12=3'b010,s21=3'b011,s22=3'b100 ;
//     wire [31:0] N11,N12,N21,N22,E11,E12,E21,E22;
//     wire wr1,wr2,wr3,wr4,wr5,wr6,wr7,wr8,wr9,wr10,wr11,wr12;
//     assign {wr12,wr11,wr10,wr9,wr8,wr7,wr6,wr5,wr4,wr3,wr2,wr1}= wr ;
//     sa_shift_register i11(clk,rst11,wr1,data_in[31:0],si11,E11);
//     sa_shift_register i12(clk,rst12,wr2,data_in[63:32],si12,E12);
//     sa_shift_register i21(clk,rst21,wr3,data_in[95:64],si21,E21);
//     sa_shift_register i22(clk,rst22,wr4,data_in[127:96],si22,E22);
//     sa_shift_register w11(clk,rst11,wr5,data_in[159:128],sw11,N11);
//     sa_shift_register w12(clk,rst12,wr6,data_in[191:160],sw12,N12);
//     sa_shift_register w21(clk,rst21,wr7,data_in[223:192],sw21,N21);
//     sa_shift_register w22(clk,rst22,wr8,data_in[255:224],sw22,N22);
//     sa_shift_register o11(clk,rst11,wr9,out11,out_s11,out_tot[31:0]);
//     sa_shift_register o12(clk,rst12,wr10,out12,out_s12,out_tot[63:32]);
//     sa_shift_register o21(clk,rst21,wr11,out21,out_s21,out_tot[95:64]);
//     sa_shift_register o22(clk,rst22,wr12,out22,out_s22,out_tot[127:96]);
//     always @(posedge clk)begin
//         $display("er11:%b,ec11:%b,er12:%b,ec21:%b",er11,ec11,er12,ec21) ; 
//     end
//     //clk,rst,N,E,out_E,out_N,out_acc,en_store,en_share,out_en
//     SM sm11(r_ctrl11,rd_i11,rd_w11,wd11,wd_val11,count_start11,rd_vali11,rd_valw11,clk,rst11,N11,E11,e11,n11,out11,en_store11[6:0],en_store11[7:1],out_en11,s11,get_addi11,get_addw11,get_wadd11);
//     SM sm12(r_ctrl12,rd_i12,rd_w12,wd12,wd_val12,count_start12,rd_vali12,rd_valw12,clk,rst12,N12,ec11?E12:e11,e12,n12,out12,en_store12[6:0],en_store12[7:1],out_en12,s12,get_addi12,get_addw12,get_wadd12);
//     SM sm21(r_ctrl21,rd_i21,rd_w21,wd21,wd_val21,count_start21,rd_vali21,rd_valw21,clk,rst21,er11?N21:n11,E21,e21,n21,out21,en_store21[6:0],en_store21[7:1],out_en21,s21,get_addi21,get_addw21,get_wadd21);
//     SM sm22(r_ctrl22,rd_i22,rd_w22,wd22,wd_val22,count_start22,rd_vali22,rd_valw22,clk,rst22,er12?N22:n12,ec21?E22:e21,e22,n22,out22,en_store22[6:0],en_store22[7:1],out_en22,s22,get_addi22,get_addw22,get_wadd22);
//     //interept (store current state).
//     //
    
// endmodule
