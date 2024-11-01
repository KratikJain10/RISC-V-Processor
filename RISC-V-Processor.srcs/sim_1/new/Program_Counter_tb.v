`timescale 1ns / 1ps

module PC_tb;
    reg clk;
    reg rst;
    reg branch_request;
    reg [31:0] branch_pc;
    reg stall;
    wire [31:0] pc_out;

    programCounter uut (
        .clk_i(clk),
        .rst_i(rst),
        .branch_req_i(branch_request),
        .branch_pc_i(branch_pc),
        .stall_i(stall),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1; branch_request = 0; branch_pc = 32'b0; stall = 0;
        #10; rst = 0;

        #10; $display("PC = %h (Expected = 0x00000004)", pc_out);
        #10; $display("PC = %h (Expected = 0x00000008)", pc_out);
        #10; branch_request = 1; branch_pc = 32'h0000001C; #10;
        $display("PC = %h (Expected = 0x0000001C)", pc_out);
        branch_request = 0;

        #10; $display("PC = %h (Expected = 0x00000020)", pc_out);
        #10; stall = 1; #10; $display("PC = %h (Expected = 0x00000020 - should not change due to stall)", pc_out);
        stall = 0;

        #10; $display("PC = %h (Expected = 0x00000024)", pc_out);
        #10; rst = 1; #10; rst = 0; $display("PC = %h (Expected = 0x00000004 after reset)", pc_out);
        #20; $finish;
    end

endmodule
