`timescale 1ns/1ps
module fetch_Unit_IF_tb;

// Clock and Reset
    reg clk_i;
    reg rst_i;

    // Fetch Interface
    wire fetch_valid_o;
    wire [31:0] fetch_instr_o;
    wire [31:0] fetch_pc_o;
    wire fetch_fault_fetch_o;
    reg fetch_accept_i;

    // Instruction Memory Interface
    wire imem_rd_o;
    wire [31:0] imem_addr_o;
    wire imem_ready_i;
    wire imem_error_i;
    wire [31:0] imem_inst_i;

    // Control Signals
    reg fetch_invalidate_i;
    reg branch_request_i;
    reg [31:0] branch_pc_i;
    wire squash_decode_o;

    // Instantiate the riscv_fetch module
    fetch_Unit_IF uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .fetch_accept_i(fetch_accept_i),
        .imem_ready_i(imem_ready_i),
        .imem_error_i(imem_error_i),
        .imem_inst_i(imem_inst_i),
        .fetch_invalidate_i(fetch_invalidate_i),
        .branch_request_i(branch_request_i),
        .branch_pc_i(branch_pc_i),
        .fetch_valid_o(fetch_valid_o),
        .fetch_instr_o(fetch_instr_o),
        .fetch_pc_o(fetch_pc_o),
        .fetch_fault_fetch_o(fetch_fault_fetch_o),
        .imem_rd_o(imem_rd_o),
        .imem_addr_o(imem_addr_o),
        .squash_decode_o(squash_decode_o)
    );

    // Instantiate the instruction memory
    instructions_memory #(
        .MEM_DEPTH(256) // Adjust size as needed
    ) imem_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd_i(imem_rd_o),
        .addr_i(imem_addr_o),
        .ready_o(imem_ready_i),
        .error_o(imem_error_i),
        .inst_o(imem_inst_i)
    );

    // Clock Generation
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; // 100 MHz clock
    end

    // Reset Generation
    initial begin
        rst_i = 1;
        #10 rst_i = 0;
    end

    // Fetch Accept Signal
    initial begin
        fetch_accept_i = 1; // Always accept fetched instructions
    end

    // Control Signals Initialization
    initial begin
        fetch_accept_i      = 1'b1;
    fetch_invalidate_i  = 1'b0;
    branch_request_i    = 1'b0;
    branch_pc_i         = 32'b0;
    end

    // Test Scenario
    initial begin
        // Wait for reset deassertion
        @(negedge rst_i);

        // Wait for some cycles
        repeat (5) @(posedge clk_i);

        // Issue a branch request to address 0x00000010
        branch_request_i <= 1;
        branch_pc_i <= 32'h00000004;
        @(posedge clk_i);
        branch_request_i <= 0;

        // Wait for some cycles to fetch instructions after the branch
        repeat (10) @(posedge clk_i);

        // Issue another branch request to address 0x00000020
        branch_request_i <= 1;
        branch_pc_i <= 32'h00000020;
        @(posedge clk_i);
        branch_request_i <= 0;

        // Wait for some cycles
        repeat (10) @(posedge clk_i);

        // Finish simulation
        $finish;
    end

    // Monitor fetched instructions
    always @(posedge clk_i) begin
        if (fetch_valid_o && fetch_accept_i) begin
            $display("Time: %0t | PC: 0x%08h | Instruction: 0x%08h", $time, fetch_pc_o, fetch_instr_o);
        end
    end

endmodule