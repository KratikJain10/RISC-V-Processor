`timescale 1ns/1ps
module instructions_memory
(
    input           clk_i,
    input           rst_i,
    input           rd_i,
    input  [31:0]   addr_i,
    output reg      ready_o,         // Single-cycle ready signal
    output          error_o,         // Error signal for out-of-bounds access
    output reg [31:0] inst_o         // Instruction output
);

    // Memory size parameters
    parameter MEM_DEPTH = 1024; // Number of instructions
    parameter MEM_ADDR_WIDTH = $clog2(MEM_DEPTH);

    // Memory array
    (* ram_style = "block" *) reg [31:0] mem_array [0:MEM_DEPTH-1];

    // Initialize memory from file
    initial begin
        $readmemh("/home/kratikjain10/Desktop/Vivado_Projects/RISC-V-Processor/RISC-V-Processor.srcs/sources_1/new/imem.mem", mem_array);
    end

    // State machine to handle `ready_o` and `inst_o` updates
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            inst_o  <= 32'b0;
            ready_o <= 1'b0;
        end else begin
            // Only respond when `rd_i` is high
            if (rd_i) begin
                inst_o  <= mem_array[addr_i[MEM_ADDR_WIDTH+1:2]]; // Update data output
                ready_o <= 1'b1; // Pulse `ready_o` high
            end else begin
                ready_o <= 1'b0; // Reset `ready_o` when `rd_i` is low
            end
        end
    end

    // Error output for out-of-bounds address
    assign error_o = (addr_i[MEM_ADDR_WIDTH+1:2] >= MEM_DEPTH);

endmodule
