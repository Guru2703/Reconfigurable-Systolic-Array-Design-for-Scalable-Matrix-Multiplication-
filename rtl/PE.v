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
    clk, inp_n, inp_e, out_n, out_e, out_acc, en_share, en_store, rst, en_out
);
    input clk;
    input rst, en_store, en_out, en_share;
    input [7:0] inp_n, inp_e;             // Inputs from north and east directions
    output [7:0] out_n, out_e;            // Outputs to south and west directions
    output [7:0] out_acc;                 // Output accumulated result
    reg [7:0] N, E;                       // Internal registers to store incoming data from N and E

//    wire [15:0] mul_result;             // Uncomment if scaling of multiplication result is needed
//    assign mul_result = inp_n * inp_e;
//    wire [7:0] scaled_mul = mul_result[13:6]; // Example: take middle 8 bits (Q8.8 fixed-point like)

    reg [7:0] ACC;                        // Accumulator register for partial sum

    always @(posedge clk) begin
        if (rst) begin                   // Reset condition clears all internal registers
            N <= 0;
            E <= 0;
            ACC <= 0;
        end

        if (en_store) begin              // Store inputs and compute partial product accumulation
            N <= inp_n;                  // Capture current north input
            E <= inp_e;                  // Capture current east input
            ACC <= ACC + inp_n * inp_e;  // Accumulate product into ACC
            $display("North:%b,East:%b", inp_n, inp_e); // Debug: display captured inputs
            $display("ACC:%b", ACC);     // Debug: display current value of accumulator
        end
    end

    // Conditional sharing of stored inputs to neighbor PEs
    assign out_n = en_share ? N : 0;      // Share north input if enabled
    assign out_e = en_share ? E : 0;      // Share east input if enabled

    // Conditional output of accumulated value
    assign out_acc = en_out ? ACC : 0;    // Output ACC if enabled
endmodule



// module PE(
// clk,inp_n,inp_e,out_n,out_e,out_acc,en_share,en_store,rst,en_out
//     );
//     input clk;
//     input rst,en_store,en_out,en_share;
//     input [7:0] inp_n,inp_e;
//     output [7:0] out_n,out_e;
//     output [7:0] out_acc;
//     reg [7:0] N,E;
// //    wire [15:0] mul_result;
// //    assign mul_result = inp_n * inp_e;
// //    wire [7:0] scaled_mul = mul_result[13:6];

//     reg [7:0] ACC;
  
//     always @(posedge clk)begin
//         //$display("North:%b,east:%b",inp_n,inp_e);
//         if(rst)begin
//             N<=0;
//             E<=0;
//             ACC<=0;
//         end
//         if(en_store)begin
//             N<=inp_n;
//             E<=inp_e;
//             ACC<=ACC+inp_n*inp_e;
//             $display("North:%b,East:%b",inp_n,inp_e) ; 
//             $display("ACC:%b",ACC);
//         end
//     end
//     assign out_n = en_share?N:0;
//     assign out_e = en_share?E:0;
//     assign out_acc = en_out?ACC:0;
// endmodule
