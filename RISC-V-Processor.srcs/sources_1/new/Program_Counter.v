`timescale 1ns / 1ps



module programCounter(input clk_i,
                            rst_i,
                            branch_req_i,
                            stall_i,
                            [31:0] branch_pc_i,
                            output reg [31:0] pc_out
                            );
                 reg [31:0] next_pc;

    always @(*) begin

        next_pc = pc_out + 32'd4;

       
        if (branch_req_i) begin
            next_pc = branch_pc_i;
        end
    end

    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            pc_out <= 32'b0; 
        end else if (!stall_i) begin
            pc_out <= next_pc; 
        end
    end
                            
                            
endmodule
