module rr_arb #(
    parameter int N = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [N-1:0]     req,
    output logic [N-1:0]     gnt,
    output logic             gnt_valid
);

    localparam PTR_W = $clog2(N);
    logic [PTR_W-1:0] ptr;

    // Step 1: rotate req so ptr position appears at bit 0
    logic [N-1:0] req_rot;
    always_comb begin
        for (int i = 0; i < N; i++)
            req_rot[i] = req[(i + ptr) % N];
    end

    // Step 2: priority encode — lowest bit of rotated req wins
    logic [N-1:0] gnt_rot;
    assign gnt_rot = req_rot & (~req_rot + 1'b1);  // x & (-x)

    // Step 3: rotate grant back to real position
    always_comb begin
        for (int i = 0; i < N; i++)
            gnt[i] = gnt_rot[(i - ptr + N) % N];
    end

    assign gnt_valid = |gnt;

    // Step 4: advance pointer past the winner
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptr <= '0;
        end else if (gnt_valid) begin
            for (int i = 0; i < N; i++)
                if (gnt[i]) ptr <= PTR_W'((i + 1) % N);
        end
    end

endmodule
