`timescale 1ns/1ps
module instructions_memory
(
    input           clk_i,
    input           rst_i,
    input           rd_i,
    input  [31:0]   addr_i,
    output          ready_o,
    output          error_o,
    output [31:0]   inst_o
);

    
    // Instruction Memory (BRAM)
    // Memory size parameters
    parameter MEM_DEPTH = 1024; // Number of instructions
    parameter MEM_ADDR_WIDTH = $clog2(MEM_DEPTH);

    // Memory array
    reg [31:0] mem_array [0:MEM_DEPTH-1];

    // Read process
    reg [31:0] data_q;
    reg        ready_q;

    // Initialization of memory from a file
    initial begin
        $readmemh("/home/kratikjain10/Desktop/Vivado_Projects/RISC-V-Processor/RISC-V-Processor.srcs/sources_1/new/imem.mem", mem_array);
    end

    // Read operation
    always @(posedge clk_i) begin
        if (rst_i) begin
            data_q  <= 32'b0;
            ready_q <= 1'b0;
        end else if (rd_i) begin
            // Address alignment (assuming word-aligned addresses)
            data_q  <= mem_array[addr_i[MEM_ADDR_WIDTH+1:2]];
            ready_q <= 1'b1;
        end else begin
            ready_q <= 1'b0;
        end
    end

    // Output assignments
    assign inst_o  = data_q;
    assign ready_o = ready_q;
    assign error_o = 1'b0; // No error handling implemented

endmodule
