module rr_arbiter_tb();

reg clk;       // Clock signal
reg rst;       // Reset signal
reg req3;      // Request signal for unit 3
reg req2;      // Request signal for unit 2
reg req1;      // Request signal for unit 1
reg req0;      // Request signal for unit 0
wire gnt3;     // Grant signal for unit 3
wire gnt2;     // Grant signal for unit 2
wire gnt1;     // Grant signal for unit 1
wire gnt0;     // Grant signal for unit 0

// Clock generator: toggle the clock every 1 time unit
always #1 clk = ~clk;

initial begin 
    // Create a VCD file for waveform viewing
    $dumpfile("rr_arbiter.vcd");
    $dumpvars();

    // Initialize signals
    clk = 0;
    rst = 1;
    req0 = 0;
    req1 = 0;
    req2 = 0;
    req3 = 0;

    // Wait for 10 time units
    #10 rst = 0;  // Release reset

    // Generate different request patterns to test the arbiter
    repeat(1) @(posedge clk);
    req0 <= 1;    // Request unit 0
    repeat(1) @(posedge clk);
    req0 <= 0;    // Stop requesting unit 0

    repeat(1) @(posedge clk);
    req0 <= 1;    // Request unit 0 again
    req1 <= 1;    // Request unit 1

    repeat(1) @(posedge clk);
    req2 <= 1;    // Request unit 2
    req1 <= 0;    // Stop requesting unit 1

    repeat(1) @(posedge clk);
    req3 <= 1;    // Request unit 3
    req2 <= 0;    // Stop requesting unit 2

    repeat(1) @(posedge clk);
    req3 <= 0;    // Stop requesting unit 3

    repeat(1) @(posedge clk);
    req0 <= 0;    // Stop requesting unit 0

    repeat(1) @(posedge clk);
    #10 $finish;  // End simulation after some time
end

// Instantiate the Round Robin Arbiter
rr_arbiter U(
    clk,
    rst,
    req3,
    req2,
    req1,
    req0,
    gnt3,
    gnt2,
    gnt1,
    gnt0
);

endmodule
