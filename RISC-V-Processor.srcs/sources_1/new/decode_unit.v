`timescale 1ns / 1ps


module decode_unit
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_MULDIV   = 1
    
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           fetch_in_valid_i
    ,input  [ 31:0]  fetch_in_instr_i
    ,input  [ 31:0]  fetch_in_pc_i
    ,input           fetch_in_fault_fetch_i
    ,input           decode_out_accept_i
    ,input           squash_decode_i

    // Outputs
    ,output          fetch_in_accept_o
    ,output          decode_out_valid_o
    ,output [ 31:0]  decode_out_instr_o
    ,output [ 31:0]  decode_out_pc_o
    ,output          deoce_fault_out
    ,output          is_instr_exec_o
    ,output          is_instr_lsu_o
    ,output          is_instr_branch_o
    ,output          is_instr_mul_o
    ,output          is_instr_div_o
    ,output          dest_rd_valid_o
    ,output          is_instr_invalid_o
);



wire        enable_muldiv_w     = SUPPORT_MULDIV;


generate
begin
    wire [31:0] fetch_in_instr_w = (fetch_in_fault_fetch_i) ? 32'b0 : fetch_in_instr_i;
    wire decode_valid = fetch_in_valid_i && !squash_decode_i;
    wire [31:0] decoded_instr = squash_decode_i ? 32'b0 : fetch_in_instr_w;
    wire [31:0] decoded_pc = squash_decode_i ? 32'b0 : fetch_in_pc_i; 
    decoder
    u_dec
    ( 
         .valid_i(decode_valid)
        ,.fetch_fault_i(fetch_in_fault_fetch_i)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(decoded_instr)
        ,.invalid_o(is_instr_invalid_o)
        ,.exec_o(is_instr_exec_o)
        ,.lsu_o(is_instr_lsu_o)
        ,.branch_o(is_instr_branch_o)
        ,.mul_o(is_instr_mul_o)
        ,.div_o(is_instr_div_o)
        ,.rd_valid_o(dest_rd_valid_o)
    );

   
    assign decode_out_valid_o        = decode_valid;
    assign decode_out_pc_o           = decoded_pc;
    assign decode_out_instr_o        = decoded_instr;
  
    assign deoce_fault_out  = fetch_in_fault_fetch_i && !squash_decode_i;

    assign fetch_in_accept_o        = decode_out_accept_i;
end
endgenerate


endmodule
