`timescale 1ns / 1ps

module reg_file_tb;
 reg clk_i;
    reg rst_i;
    reg [4:0] rd0_i;
    reg [31:0] rd0_value_i;
    reg rd0_we_i;
    reg [4:0] ra0_i;
    reg [4:0] rb0_i;
    wire [31:0] ra0_value_o;
    wire [31:0] rb0_value_o;

    // Instantiate the register file
    register_file uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .rd0_i(rd0_i),
        .rd0_value_i(rd0_value_i),
        .rd0_we_i(rd0_we_i),
        .ra0_i(ra0_i),
        .rb0_i(rb0_i),
        .ra0_value_o(ra0_value_o),
        .rb0_value_o(rb0_value_o)
    );

    // Clock generation
    initial begin
        clk_i = 1'b0;
        forever #5 clk_i = ~clk_i;  // 10 ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_i = 1'b1;
        rd0_i = 5'b0;
        rd0_value_i = 32'b0;
        rd0_we_i = 1'b0;
        ra0_i = 5'b0;
        rb0_i = 5'b0;

        // Apply reset
        #10;
        rst_i = 1'b0;

        // Test case 1: Write to registers and read back
        #10;
        rd0_i = 5'd1;         // Write to register 1
        rd0_value_i = 32'hA5A5A5A5;
        rd0_we_i = 1'b1;

        #10;
        rd0_i = 5'd2;         // Write to register 2
        rd0_value_i = 32'h5A5A5A5A;
        rd0_we_i = 1'b1;

        #10;
        rd0_we_i = 1'b0;      // Stop writing

        // Read back the values
        #10;
        ra0_i = 5'd1;         // Read from register 1
        rb0_i = 5'd2;         // Read from register 2

        #10;
        $display("ra0_value_o = %h (Expected: A5A5A5A5)", ra0_value_o);
        $display("rb0_value_o = %h (Expected: 5A5A5A5A)", rb0_value_o);

        // Test case 2: Verify register 0 is always zero
        #10;
        ra0_i = 5'd0;         // Read from register 0
        rb0_i = 5'd0;         // Read from register 0

        #10;
        $display("ra0_value_o = %h (Expected: 00000000)", ra0_value_o);
        $display("rb0_value_o = %h (Expected: 00000000)", rb0_value_o);

        // Test case 3: Overwrite register 1 and read back
        #10;
        rd0_i = 5'd1;         // Write to register 1 again
        rd0_value_i = 32'h12345678;
        rd0_we_i = 1'b1;

        #10;
        rd0_we_i = 1'b0;      // Stop writing
        ra0_i = 5'd1;         // Read from register 1

        #10;
        $display("ra0_value_o = %h (Expected: 12345678)", ra0_value_o);

        // Test completed
        #10;
        $finish;
    end

endmodule