`timescale 1ns/1ps
module register_file
(
    // Inputs
     input           clk_i,
     input           rst_i,
     input  [  4:0]  rd0_i,           // Write address
     input  [ 31:0]  rd0_value_i,     // Write data       // Write enable
     input  [  4:0]  ra0_i,           // Read address A
     input  [  4:0]  rb0_i,           // Read address B

    // Outputs
    output [ 31:0]  ra0_value_o,      // Read data A
    output [ 31:0]  rb0_value_o       // Read data B
);
//-----------------------------------------------------------------
// Register File Storage (32x32-bit Distributed RAM)
//-----------------------------------------------------------------
(* ram_style = "distributed" *) reg [31:0] register_file [0:31];

//-----------------------------------------------------------------
// Write Logic (Synchronous)
//-----------------------------------------------------------------
always @(posedge clk_i) begin
    if (rd0_i != 5'b00000) begin
        register_file[rd0_i] <= rd0_value_i;  // Write to register file (excluding x0)
    end
end

//-----------------------------------------------------------------
// Read Logic (Asynchronous)
//-----------------------------------------------------------------
assign ra0_value_o = (ra0_i == 5'b00000) ? 32'b0 : register_file[ra0_i]; // Read port A
assign rb0_value_o = (rb0_i == 5'b00000) ? 32'b0 : register_file[rb0_i]; // Read port B

endmodule
