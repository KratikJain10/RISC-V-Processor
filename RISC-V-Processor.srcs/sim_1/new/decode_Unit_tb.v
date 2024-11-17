`timescale 1ns / 1ps

module decode_Unit_tb;
 parameter SUPPORT_MULDIV = 1;

    reg clk_i;
    reg rst_i;
    reg fetch_in_valid_i;
    reg [31:0] fetch_in_instr_i;
    reg [31:0] fetch_in_pc_i;
    reg fetch_in_fault_fetch_i;
    reg fetch_out_accept_i;
    reg squash_decode_i;

    wire fetch_in_accept_o;
    wire fetch_out_valid_o;
    wire [31:0] fetch_out_instr_o;
    wire [31:0] fetch_out_pc_o;
    wire fetch_out_fault_fetch_o;
    wire fetch_out_instr_exec_o;
    wire fetch_out_instr_lsu_o;
    wire fetch_out_instr_branch_o;
    wire fetch_out_instr_mul_o;
    wire fetch_out_instr_div_o;
    wire fetch_out_instr_rd_valid_o;
    wire fetch_out_instr_invalid_o;

    decode_unit #(
        .SUPPORT_MULDIV(SUPPORT_MULDIV)
    ) uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .fetch_in_valid_i(fetch_in_valid_i),
        .fetch_in_instr_i(fetch_in_instr_i),
        .fetch_in_pc_i(fetch_in_pc_i),
        .fetch_in_fault_fetch_i(fetch_in_fault_fetch_i),
        .fetch_out_accept_i(fetch_out_accept_i),
        .squash_decode_i(squash_decode_i),
        .fetch_in_accept_o(fetch_in_accept_o),
        .fetch_out_valid_o(fetch_out_valid_o),
        .fetch_out_instr_o(fetch_out_instr_o),
        .fetch_out_pc_o(fetch_out_pc_o),
        .fetch_out_fault_fetch_o(fetch_out_fault_fetch_o),
        .fetch_out_instr_exec_o(fetch_out_instr_exec_o),
        .fetch_out_instr_lsu_o(fetch_out_instr_lsu_o),
        .fetch_out_instr_branch_o(fetch_out_instr_branch_o),
        .fetch_out_instr_mul_o(fetch_out_instr_mul_o),
        .fetch_out_instr_div_o(fetch_out_instr_div_o),
        .fetch_out_instr_rd_valid_o(fetch_out_instr_rd_valid_o),
        .fetch_out_instr_invalid_o(fetch_out_instr_invalid_o)
    );

    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin
        rst_i = 1;
        fetch_in_valid_i = 0;
        fetch_in_instr_i = 0;
        fetch_in_pc_i = 0;
        fetch_in_fault_fetch_i = 0;
        fetch_out_accept_i = 0;
        squash_decode_i = 0;

        #10;
        rst_i = 0;

        #10;
        fetch_in_valid_i = 1;
        fetch_in_instr_i = 32'b000000000001_00001_000_00010_0010011;
        fetch_in_pc_i = 32'h0000_0004;
        fetch_out_accept_i = 1;

        #10;
        fetch_in_instr_i = 32'b0000001_00010_00001_000_00011_0110011;

        #10;

        #10;
        fetch_in_instr_i = 32'hFFFFFFFF;

        #10;

        #10;
        fetch_in_instr_i = 32'b0000000_00001_00010_000_00000_1100011;

        #10;

        #10;
        fetch_in_fault_fetch_i = 1;

        #10;

        #10;
        fetch_in_fault_fetch_i = 0;
        squash_decode_i = 1;

        #10;

        #20;
        $stop;
    end
endmodule