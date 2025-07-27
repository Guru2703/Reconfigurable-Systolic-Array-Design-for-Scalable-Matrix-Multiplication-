`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2024 14:42:28
// Design Name: 
// Module Name: SM
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

module SM(
    r_ctrl ,rd_i,rd_w,wd,wd_val,count_start,rd_vali,rd_valw,
    clk,rst,N,E,out_E,out_N,out_acc,en_store,en_share,out_en,sno,
    get_addi, get_addw, get_wadd
);

// === Input Declarations ===
input r_ctrl;                       // Select between r_add_1 and r_add_2
input [1:0] rd_i, rd_w, wd;         // Control signals for read/write (input/weight/output)
input count_start;                 // Starts counter for memory access tracking
input [8:0] rd_valw, rd_vali, wd_val; // Base read/write addresses for input, weight, and output
input clk, rst;
input [31:0] N, E;                  // Input data from North and East
input [6:0] en_store, en_share;     // Enable storing/sharing per PE
input [3:0] out_en;                 // Enable output accumulation per row
input [2:0] sno;                    // Unique identifier for the SM block

// === Output Declarations ===
output [31:0] out_E, out_N;         // Output to East and North neighbors
output [31:0] out_acc;              // Accumulated output (4 PEs per row)
output [8:0] get_addi, get_addw;    // Computed read addresses for input/weight
output [8:0] get_wadd;              // Computed write address for output

// === Internal Registers ===
reg [1:0] counter;                  // Keeps track of how many cycles into computation
reg [8:0] r_add_i1, r_add_w1, r_add_i2, r_add_w2, wd_add; // Address storage registers

// === Address and Control Logic ===
always @(posedge clk) begin
    if (rd_i[0]) begin
        counter <= 0;              // Reset counter at beginning of new input read
        r_add_i1 <= rd_vali;
    end
    if (rd_i[1]) begin
        r_add_i2 <= rd_vali;
    end
    if (rd_w[0]) begin
        r_add_w1 <= rd_valw;
    end
    if (rd_w[1]) begin
        r_add_w2 <= rd_valw;
    end
    if (count_start) begin
        counter <= counter + 1;    // Increment counter when computation starts
    end
    if (wd) begin
        wd_add = wd_val;
    end

    // === Debugging/Visualization ===
    $display("r_ctrl:%b", r_ctrl);
    $display("SM_no:%b", sno);
    $display("r_id:%b", rd_i);
    $display("r_add1:%b", r_add_i1);
    $display("r_add2:%b", r_add_i2);
    $display("w_add1:%b", r_add_w1);
    $display("w_add2:%b", r_add_w2);
    $display("wd_add:%b", wd_add);
    $display("counter:%b", counter);
    $display("en_share for pe:%b", en_share);
    $display("n11:%h,n12:%h,n13:%h,n14:%h", n11, n12, n13, n14);
    $display("n21:%h,n22:%h,n23:%h,n24:%h", n21, n22, n23, n24);
    $display("n31:%h,n32:%h,n33:%h,n34:%h", n31, n32, n33, n34);
    $display("n41:%h,n42:%h,n43:%h,n44:%h", n41, n42, n43, n44);
    $display("e11:%h,e12:%h,e13:%h,e14:%h", e11, e12, e13, e14);
    $display("e21:%h,e22:%h,e23:%h,e24:%h", e21, e22, e23, e24);
    $display("e31:%h,e32:%h,e33:%h,e34:%h", e31, e32, e33, e34);
    $display("e41:%h,e42:%h,e43:%h,e44:%h", e41, e42, e43, e44);
end

// === Internal Wires for PE Outputs ===
wire [7:0] o11,o12,o13,o14,o21,o22,o23,o24,o31,o32,o33,o34,o41,o42,o43,o44;
wire [7:0] e11,e12,e13,e14,e21,e22,e23,e24,e31,e32,e33,e34,e41,e42,e43,e44;
wire [7:0] n11,n12,n13,n14,n21,n22,n23,n24,n31,n32,n33,n34,n41,n42,n43,n44;

// === PE Grid Instantiations (4x4 Array) ===
// Row 1
PE pe11(clk, N[7:0],   E[7:0],   n11, e11, o11, en_share[0], en_store[0], rst, out_en[0]);
PE pe12(clk, N[15:8],  e11,     n12, e12, o12, en_share[1], en_store[1], rst, out_en[0]);
PE pe13(clk, N[23:16], e12,     n13, e13, o13, en_share[2], en_store[2], rst, out_en[0]);
PE pe14(clk, N[31:24], e13,     n14, e14, o14, en_share[3], en_store[3], rst, out_en[0]);

// Row 2
PE pe21(clk, n11,      E[15:8], n21, e21, o21, en_share[1], en_store[1], rst, out_en[1]);
PE pe22(clk, n12,      e21,     n22, e22, o22, en_share[2], en_store[2], rst, out_en[1]);
PE pe23(clk, n13,      e22,     n23, e23, o23, en_share[3], en_store[3], rst, out_en[1]);
PE pe24(clk, n14,      e23,     n24, e24, o24, en_share[4], en_store[4], rst, out_en[1]);

// Row 3
PE pe31(clk, n21,      E[23:16],n31, e31, o31, en_share[2], en_store[2], rst, out_en[2]);
PE pe32(clk, n22,      e31,     n32, e32, o32, en_share[3], en_store[3], rst, out_en[2]);
PE pe33(clk, n23,      e32,     n33, e33, o33, en_share[4], en_store[4], rst, out_en[2]);
PE pe34(clk, n24,      e33,     n34, e34, o34, en_share[5], en_store[5], rst, out_en[2]);

// Row 4
PE pe41(clk, n31,      E[31:24],n41, e41, o41, en_share[3], en_store[3], rst, out_en[3]);
PE pe42(clk, n32,      e41,     n42, e42, o42, en_share[4], en_store[4], rst, out_en[3]);
PE pe43(clk, n33,      e42,     n43, e43, o43, en_share[5], en_store[5], rst, out_en[3]);
PE pe44(clk, n34,      e43,     n44, e44, o44, en_share[6], en_store[6], rst, out_en[3]);

// === Output Selection for Accumulator (based on row enable) ===
assign out_acc[7:0]    = out_en[0] ? o11 : out_en[1] ? o21 : out_en[2] ? o31 : out_en[3] ? o41 : 0;
assign out_acc[15:8]   = out_en[0] ? o12 : out_en[1] ? o22 : out_en[2] ? o32 : out_en[3] ? o42 : 0;
assign out_acc[23:16]  = out_en[0] ? o13 : out_en[1] ? o23 : out_en[2] ? o33 : out_en[3] ? o43 : 0;
assign out_acc[31:24]  = out_en[0] ? o14 : out_en[1] ? o24 : out_en[2] ? o34 : out_en[3] ? o44 : 0;

// === Output Connections to Neighboring SMs ===
assign out_E[31:24] = e44;
assign out_E[23:16] = e34;
assign out_E[15:8]  = e24;
assign out_E[7:0]   = e14;

assign out_N[31:24] = n44;
assign out_N[23:16] = n34;
assign out_N[15:8]  = n24;
assign out_N[7:0]   = n14;

// === Address Generator for Memory Communication ===
wire [8:0] r_add_i = r_ctrl ? r_add_i2 : r_add_i1;
wire [8:0] r_add_w = r_ctrl ? r_add_w2 : r_add_w1;

assign get_addi = r_add_i + counter; // Input read address
assign get_addw = r_add_w + counter; // Weight read address
assign get_wadd = wd_add  + counter; // Output write address

endmodule



// module SM(
// r_ctrl ,rd_i,rd_w,wd,wd_val,count_start,rd_vali,rd_valw,clk,rst,N,E,out_E,out_N,out_acc,en_store,en_share,out_en,sno,get_addi ,get_addw
// ,get_wadd
//     );
   
//     input r_ctrl ; 
//     input [1:0] rd_i,rd_w,wd;
//     input count_start; 
//     input [8:0] rd_valw,rd_vali,wd_val; 
//     input clk,rst;
//     output [31:0] out_E,out_N;
//     output [31:0] out_acc;
//     input [6:0]en_store,en_share;
//     input [3:0] out_en;
//     input [31:0] N,E;
//     input [2:0] sno; 
//     output [8:0] get_addi,get_addw,get_wadd ; 
//     reg [1:0] counter ;
//     //wire[31:0] out_acc;
//     reg [8:0] r_add_i1 ,r_add_w1,r_add_i2 ,r_add_w2 ,wd_add; 
//     always @(posedge clk)begin
//         if(rd_i[0])begin
//             counter <=0 ;
//             r_add_i1 <= rd_vali;
//             end 
//         if(rd_i[1])begin    
//             r_add_i2 <=rd_vali; 
             
//             end
//         if(rd_w[0])begin
//             r_add_w1 <= rd_valw;
//             end 
//         if(rd_w[1])begin
//             r_add_w2 <= rd_valw; 
//         end
//         if(count_start)begin
//             counter<= counter+1 ; 
//         end
//         if(wd)begin
//             wd_add = wd_val ; 
//         end
        
//         $display("r_ctrl:%b",r_ctrl) ; 
//         $display("SM_no:%b",sno);
//         $display("r_id:%b",rd_i);
//         $display("r_add1:%b",r_add_i1); 
//         $display("r_add2:%b",r_add_i2);
//         $display("w_add1:%b",r_add_w1); 
//         $display("w_add2:%b",r_add_w2);
//         $display("wd_add:%b",wd_add);
//         $display("counter:%b",counter) ; 
//         $display("en_share for pe:%b",en_share);
//         $display("n11:%h,n12:%h,n13:%h,n14:%h",n11,n12,n13,n14);
//         $display("n21:%h,n22:%h,n23:%h,n24:%h",n21,n22,n23,n24);
//         $display("n31:%h,n32:%h,n33:%h,n34:%h",n31,n32,n33,n34);
//         $display("n41:%h,n42:%h,n43:%h,n44:%h",n41,n42,n43,n44);
//         $display("e11:%h,e12:%h,e13:%h,e14:%h",e11,e12,e13,e14);
//         $display("e21:%h,e22:%h,e23:%h,e24:%h",e21,e22,e23,e24);
//         $display("e31:%h,e32:%h,e33:%h,e34:%h",e31,e32,e33,e34);
//         $display("e41:%h,e42:%h,e43:%h,e44:%h",e41,e42,e43,e44);
//     end
//     wire [7:0] o11,o12,o13,o14,o21,o22,o23,o24,o31,o32,o33,o34,o41,o42,o43,o44;
//     wire [7:0] e11,e12,e13,e14,e21,e22,e23,e24,e31,e32,e33,e34,e41,e42,e43,e44;
//     wire [7:0] n11,n12,n13,n14,n21,n22,n23,n24,n31,n32,n33,n34,n41,n42,n43,n44;
//     PE pe11(clk,N[7:0],E[7:0],n11,e11,o11,en_share[0],en_store[0],rst,out_en[0]);
//     PE pe12(clk,N[15:8],e11,n12,e12,o12,en_share[1],en_store[1],rst,out_en[0]);
//     PE pe13(clk,N[23:16],e12,n13,e13,o13,en_share[2],en_store[2],rst,out_en[0]);
//     PE pe14(clk,N[31:24],e13,n14,e14,o14,en_share[3],en_store[3],rst,out_en[0]);
//     PE pe21(clk,n11,E[15:8],n21,e21,o21,en_share[1],en_store[1],rst,out_en[1]);
//     PE pe22(clk,n12,e21,n22,e22,o22,en_share[2],en_store[2],rst,out_en[1]);
//     PE pe23(clk,n13,e22,n23,e23,o23,en_share[3],en_store[3],rst,out_en[1]);
//     PE pe24(clk,n14,e23,n24,e24,o24,en_share[4],en_store[4],rst,out_en[1]);
//     PE pe31(clk,n21,E[23:16],n31,e31,o31,en_share[2],en_store[2],rst,out_en[2]);
//     PE pe32(clk,n22,e31,n32,e32,o32,en_share[3],en_store[3],rst,out_en[2]);
//     PE pe33(clk,n23,e32,n33,e33,o33,en_share[4],en_store[4],rst,out_en[2]);
//     PE pe34(clk,n24,e33,n34,e34,o34,en_share[5],en_store[5],rst,out_en[2]);
//     PE pe41(clk,n31,E[31:24],n41,e41,o41,en_share[3],en_store[3],rst,out_en[3]);
//     PE pe42(clk,n32,e41,n42,e42,o42,en_share[4],en_store[4],rst,out_en[3]);
//     PE pe43(clk,n33,e42,n43,e43,o43,en_share[5],en_store[5],rst,out_en[3]);
//     PE pe44(clk,n34,e43,n44,e44,o44,en_share[6],en_store[6],rst,out_en[3]);
//     assign out_acc[7:0]  = out_en[0]?o11:out_en[1]?o21:out_en[2]?o31:out_en[3]?o41:0;
//     assign out_acc[15:8] = out_en[0]?o12:out_en[1]?o22:out_en[2]?o32:out_en[3]?o42:0;
//     assign out_acc[23:16] = out_en[0]?o13:out_en[1]?o23:out_en[2]?o33:out_en[3]?o43:0;
//     assign out_acc[31:24] = out_en[0]?o14:out_en[1]?o24:out_en[2]?o34:out_en[3]?o44:0;
//     assign out_E[31:24]=e44;
//     assign out_E[23:16]=e34;
//     assign out_E[15:8]=e24;
//     assign out_E[7:0]=e14; //doubt?
//     assign out_N[31:24]=n44;
//     assign out_N[23:16]=n34;
//     assign out_N[15:8]=n24;
//     assign out_N[7:0]=n14; 
//     wire [8:0]r_add_i =r_ctrl? r_add_i2:r_add_i1 ;
//     wire [8:0]r_add_w =r_ctrl? r_add_w2:r_add_w1 ;//verify the flow
//     assign get_addi = r_add_i + counter ;
//     assign get_addw = r_add_w + counter ; 
//     assign get_wadd = wd_add + counter ; 
// endmodule
