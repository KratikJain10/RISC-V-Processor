`timescale 1ns/1ps
module fetch_Unit_IF
(
    // Inputs
    input           clk_i,
    input           rst_i,
    input           fetch_accept_i,
    input           imem_ready_i,
    input           imem_error_i,
    input  [31:0]   imem_inst_i,
    input           fetch_invalidate_i,
    input           branch_request_i,
    input  [31:0]   branch_pc_i,

    // Outputs
    output          fetch_valid_o,
    output [31:0]   fetch_instr_o,
    output [31:0]   fetch_pc_o,
    output          fetch_fault_fetch_o,
    output          imem_rd_o,
    output [31:0]   imem_addr_o,
    output          squash_decode_o
);

//-------------------------------------------------------------
// Internal Registers / Wires
//-------------------------------------------------------------
reg         active_q;
reg [1:0]   branch_squash_cnt;

// Wires for control
wire        imem_busy_w;
wire        stall_w = !fetch_accept_i || imem_busy_w || !imem_ready_i;

// Branch buffering
reg         branch_q;
reg [31:0]  branch_pc_q;

// Program counters
reg [31:0]  pc_f_q;
reg [31:0]  pc_d_q;

// Skid buffer for handling stalls
reg [64:0] skid_buffer_q;
reg        skid_valid_q;

// Request tracking
reg imem_fetch_q;

//-------------------------------------------------------------
// Branch Logic with Squash Counter
//-------------------------------------------------------------
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i) begin
        branch_squash_cnt <= 2'b00;
    end else if (branch_request_i) begin
        branch_squash_cnt <= 2'b10; // 2 cycles to squash
    end else if (branch_squash_cnt != 2'b00) begin
        branch_squash_cnt <= branch_squash_cnt - 1;
    end
end

assign squash_decode_o = (branch_squash_cnt != 2'b00) || branch_request_i;

//-------------------------------------------------------------
// Branch Buffered State
//-------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    branch_q       <= 1'b0;
    branch_pc_q    <= 32'b0;
end
else if (branch_request_i)
begin
    branch_q       <= 1'b1;
    branch_pc_q    <= branch_pc_i;
end
else if (imem_rd_o && imem_ready_i)
begin
    branch_q       <= 1'b0;
    branch_pc_q    <= 32'b0;
end

// Assign branch signals
wire        branch_w    = branch_q;
wire [31:0] branch_pc_w = branch_pc_q;

//-------------------------------------------------------------
// Active flag logic for initiating fetch
//-------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    active_q    <= 1'b1;
else if (branch_w && ~stall_w)
    active_q    <= 1'b1;

//-------------------------------------------------------------
// Request tracking for IMEM
//-------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    imem_fetch_q <= 1'b0;
else if (imem_rd_o && imem_ready_i)
    imem_fetch_q <= 1'b1;
else if (imem_ready_i)
    imem_fetch_q <= 1'b0;

assign imem_busy_w = imem_fetch_q && !imem_ready_i;

//-------------------------------------------------------------
// Program Counter Update
//-------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pc_f_q <= 32'b0;
else if (branch_w && ~stall_w)
    pc_f_q <= branch_pc_w;
else if (!stall_w)
    pc_f_q <= pc_f_q + 32'd4;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pc_d_q <= 32'b0;
else if (imem_rd_o && imem_ready_i)
    pc_d_q <= pc_f_q;

//-------------------------------------------------------------
// Output Assignments
//-------------------------------------------------------------
assign imem_rd_o          = active_q & fetch_accept_i & !imem_busy_w;
assign imem_addr_o        = {pc_f_q[31:2], 2'b0};
assign fetch_valid_o      = (imem_ready_i || skid_valid_q) && !squash_decode_o;
assign fetch_pc_o         = skid_valid_q ? skid_buffer_q[63:32] : pc_d_q;
assign fetch_instr_o      = skid_valid_q ? skid_buffer_q[31:0]  : imem_inst_i;
assign fetch_fault_fetch_o = skid_valid_q ? skid_buffer_q[64] : imem_error_i;

//-------------------------------------------------------------
// Skid Buffer Logic
//-------------------------------------------------------------
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i)
    begin
        skid_buffer_q  <= 65'b0;
        skid_valid_q   <= 1'b0;
    end
    else if (fetch_valid_o && !fetch_accept_i)
    begin
        skid_valid_q  <= 1'b1;
        skid_buffer_q <= {fetch_fault_fetch_o, fetch_pc_o, fetch_instr_o};
    end
    else
    begin
        skid_valid_q  <= 1'b0;
        skid_buffer_q <= 65'b0;
    end
end

endmodule
