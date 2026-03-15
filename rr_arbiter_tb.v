`timescale 1ns/1ps

module tb_rr_arb;

    parameter N = 4;

    logic clk;
    logic rst_n;
    logic [N-1:0] req;
    logic [N-1:0] gnt;
    logic gnt_valid;

    // DUT instantiation
    rr_arb #(N) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .gnt(gnt),
        .gnt_valid(gnt_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10ns clock period
    end

    // Stimulus
    initial begin
        $display("Time\treq\tgnt\tptr_valid");
        $monitor("%0t\t%b\t%b\t%b", $time, req, gnt, gnt_valid);

        // Reset
        rst_n = 0;
        req = 0;
        #20;
        rst_n = 1;

        // Test 1: single request
        #10 req = 4'b0001;
        #20 req = 4'b0010;
        #20 req = 4'b0100;
        #20 req = 4'b1000;

        // Test 2: multiple requests
        #20 req = 4'b1011;
        #40 req = 4'b1100;

        // Test 3: all request
        #40 req = 4'b1111;

        // Test 4: random requests
        repeat (10) begin
            #20 req = $random;
        end

        #100 $finish;
    end

endmodule
