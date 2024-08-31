module rr_arbiter(
    clk,         // Clock input
    rst,         // Reset input
    req3, req2, req1, req0,  // Request signals from 4 different units
    gnt3, gnt2, gnt1, gnt0   // Grant signals to the units
);

// Port declaration 
input clk;     // Clock signal
input rst;     // Reset signal
input req3;    // Request signal from unit 3
input req2;    
input req1;    
input req0;    
output gnt3;   // Grant signal to unit 3
output gnt2;   
output gnt1;   
output gnt0;   

// Internal signals and registers
wire [1:0] gnt;        // 2-bit wire to represent the grant signal
wire comreq;          
wire beg;              // Begin signal to indicate if arbitration can start
wire [1:0] lgnt;       // Latched encoded grant signals
wire lcomreq;          // Latched communication request signal
reg lgnt0;             // Latched grant for unit 0
reg lgnt1;             
reg lgnt2;             
reg lgnt3;             
reg mask_enable;       // Mask enable signal
reg lmask0;            // Latched mask for grant 0
reg lmask1;            // Latched mask for grant 1
reg ledge;             // Latched edge signal

// Always block : to handle the reset and update grant signals
always @(posedge clk) begin
    if (rst) begin
        // Reset all latch registers to 0
        lgnt0 <= 0;
        lgnt1 <= 0;
        lgnt2 <= 0;
        lgnt3 <= 0;
    end else begin
        // Grant logic with round-robin arbiter : here i have assumed there are 4 master request
        lgnt0 <= (~lcomreq & ~lmask1 & ~lmask0 & ~req3 & ~req2 & ~req1 & req0)    
              | (~lcomreq & ~lmask1 & lmask0 & ~req3 & ~req2 & req0)        
              | (~lcomreq & lmask1 & ~lmask0 & ~req3 & req0)                
              | (~lcomreq & lmask1 & lmask0 & req0)                         
              | (lcomreq & lgnt0);                                          

        lgnt1 <= (~lcomreq & ~lmask1 & ~lmask0 & req1)             
              | (~lcomreq & ~lmask1 & lmask0 & ~req3 & ~req2 & req1 & ~req0)
              | (~lcomreq & lmask1 & ~lmask0 & ~req3 & req1 & ~req0)
              | (~lcomreq & lmask1 & lmask0 & req1 & ~req0)
              | (lcomreq & lgnt1);

        lgnt2 <= (~lcomreq & ~lmask1 & ~lmask0 & req2 & ~req1)
              | (~lcomreq & ~lmask1 & lmask0 & req2)
              | (~lcomreq & lmask1 & ~lmask0 & ~req3 & req2 & ~req1 & ~req0)
              | (~lcomreq & lmask1 & lmask0 & req2 & ~req1 & ~req0)
              | (lcomreq & lgnt2);

        lgnt3 <= (~lcomreq & ~lmask1 & ~lmask0 & req3 & ~req2 & ~req1)
              | (~lcomreq & ~lmask1 & lmask0 & req3 & ~req2)
              | (~lcomreq & lmask1 & ~lmask0 & req3)
              | (~lcomreq & lmask1 & lmask0 & req3 & ~req2 & ~req1 & ~req0)
              | (lcomreq & lgnt3);
    end
end

// Generate 'beg' signal indicating if any request is active and arbitration can begin
assign beg = (req3 | req2 | req1 | req0) & ~lcomreq;

// Communication request signal logic(BUS STATUS)
assign lcomreq = (req3 & lgnt3)
                | (req2 & lgnt2)
                | (req1 & lgnt1)
                | (req0 & lgnt0);

// Encoder logic to encode grant signals into a 2-bit format
assign lgnt = {(lgnt3 | lgnt2), (lgnt3 | lgnt1)};

// Handle latch mask registers
always @(posedge clk) begin
    if (rst) begin  
        lmask1 <= 0;
        lmask0 <= 0;
    end else if (mask_enable) begin
        lmask1 <= lgnt[1];
        lmask0 <= lgnt[0];
    end else begin
        lmask1 <= lmask1;
        lmask0 <= lmask0;
    end
end

// Assign the final grant signals to outputs

assign comreq = lcomreq;
assign gnt = lgnt;
//drive the outputs
assign gnt3 = lgnt3;
assign gnt2 = lgnt2;
assign gnt1 = lgnt1;
assign gnt0 = lgnt0;

endmodule
