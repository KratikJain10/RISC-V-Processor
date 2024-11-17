`timescale 1ns/1ps
module fetch_Unit_IF_tb;



//-------------------------------------------------------------
// Clock and Reset Signals
//-------------------------------------------------------------
reg clk;
reg rst;

// Clock signal generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns clock period (100 MHz)
end

// Reset signal generation
initial begin
    rst = 1;
    #10 rst = 0; // Release reset after 20 ns
end

//-------------------------------------------------------------
// Input/Output Signals
//-------------------------------------------------------------
reg fetch_accept;
reg fetch_invalidate;
reg branch_request;
reg [31:0] branch_pc;

wire fetch_valid;
wire [31:0] fetch_instr;
wire [31:0] fetch_pc;
wire fetch_fault;
wire imem_rd;
wire [31:0] imem_addr;
wire squash_decode;
wire imem_ready;      // Driven by instructions_memory
wire imem_error;      // Driven by instructions_memory
wire [31:0] inst_mem_out; // Instruction output

//-------------------------------------------------------------
// DUT: Instantiate Fetch Unit and Instruction Memory
//-------------------------------------------------------------
fetch_Unit_IF u_fetch (
    .clk_i(clk),
    .rst_i(rst),
    .fetch_accept_i(fetch_accept),
    .imem_ready_i(imem_ready),   // Now wired correctly
    .imem_error_i(imem_error),
    .imem_inst_i(inst_mem_out),
    .fetch_invalidate_i(fetch_invalidate),
    .branch_request_i(branch_request),
    .branch_pc_i(branch_pc),
    .fetch_valid_o(fetch_valid),
    .fetch_instr_o(fetch_instr),
    .fetch_pc_o(fetch_pc),
    .fetch_fault_fetch_o(fetch_fault),
    .imem_rd_o(imem_rd),
    .imem_addr_o(imem_addr),
    .squash_decode_o(squash_decode)
);

instructions_memory u_imem (
    .clk_i(clk),
    .rst_i(rst),
    .rd_i(imem_rd),
    .addr_i(imem_addr),
    .ready_o(imem_ready),  // Now wired correctly
    .error_o(imem_error),
    .inst_o(inst_mem_out)
);

//-------------------------------------------------------------
// Simulation Process
//-------------------------------------------------------------
initial begin
    // Initialize control signals
    fetch_accept     = 1;
    fetch_invalidate = 0;
    branch_request   = 0;
    branch_pc        = 32'h00000024; // Example branch PC

    #30;
    
    // Wait for first instruction fetch after reset
    wait(fetch_valid);
    $display("Fetched instruction at PC: %h, instruction: %h", fetch_pc, fetch_instr);
    
    #40;
    
    // Simulate a branch request
    branch_request = 1;
    #10;
    branch_request = 0;
    wait(fetch_valid);
    $display("After branch, fetched instruction at PC: %h, instruction: %h", fetch_pc, fetch_instr);
    
    #25;
    
    // Introduce a stall (fetch accept disabled)
    fetch_accept = 0;
    #10;
    fetch_accept = 1;
    wait(fetch_valid);
    $display("After stall, fetched instruction at PC: %h, instruction: %h", fetch_pc, fetch_instr);
    
    #20;
    
    // Finish simulation
    #50;
    $finish;
end

endmodule