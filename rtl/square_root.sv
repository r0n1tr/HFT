// Fixed point square root, following this overall algorithm: https://projectf.io/posts/square-root-in-verilog/
/*
Input: X=01111001 (decimal 121)

Step  A         X         T         Q       Description
——————————————————————————————————————————————————————————————————————————————
      00000000  01111001  00000000  0000    Starting values.

1     00000001  11100100                    Left shift X by two places into A.
                          00000000          Set T = A - {Q,01}: 01 - 01.
                                    0000    Left shift Q.
      00000000                      0001    Is T≥0? Yes. Set A=T and Q[0]=1.

2     00000011  10010000                    Left shift X by two places into A.
                          11111100          Set T = A - {Q,01}: 11 - 101.
                                    0010    Left shift Q.
                                            Is T≥0? No. Move to next step.

3     00001110  01000000                    Left shift X by two places into A.
                          00000101          Set T = A - {Q,01}: 1110 - 1001
                                    0100    Left shift Q.
      00000101                      0101    Is T≥0? Yes. Set A=T and Q[0]=1.

4     00010101  00000000                    Left shift X by two places into A.
                          00000000          Set T = A - {Q,01}: 10101 - 10101.
                                    1010    Left shift Q.
      00000000                      1011    Is T≥0? Yes. Set A=T and Q[0]=1.
——————————————————————————————————————————————————————————————————————————————

Output: Q=1010 (decimal 11), R=0 (remainder taken from final A)
*/

// just experimenting with this one, not sure if its all that good though - 16 clock cycles for 32 bit fixed point numbers
module square_root
#(
    parameter WIDTH = 8,
    parameter FRACT_BITS = 0
)
(
    input logic                     i_clk,
    input logic                     i_start,            // start signal
    output logic                    o_busy,             // calculation in progress
    output logic                    o_valid,            // root and rem are valid
    input logic [WIDTH-1:0]         i_rad,              // radicand
    output logic [WIDTH-1:0]        o_root,             // root
    output logic [WIDTH-1:0]        o_rem               // remainder
);

    logic [WIDTH-1:0] x, x_next;    // radicand copy
    logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
    logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
    logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)

    localparam ITER = (WIDTH+FRACT_BITS) >> 1;  // iterations are half radicand+fbits width
    logic [$clog2(ITER)-1:0] i;            // iteration counter

    always_comb begin
        test_res = ac - {q, 2'b01};
        if (test_res[WIDTH+1] == 0) begin  // test_res ≥0? (check MSB)
            {ac_next, x_next} = {test_res[WIDTH-1:0], x, 2'b0};
            q_next = {q[WIDTH-2:0], 1'b1};
        end else begin
            {ac_next, x_next} = {ac[WIDTH-1:0], x, 2'b0};
            q_next = q << 1;
        end
    end    

        always_ff @(posedge i_clk) begin
        if (i_start) begin
            o_busy <= 1;
            o_valid <= 0;
            i <= 0;
            q <= 0;
            {ac, x} <= {{WIDTH{1'b0}}, i_rad, 2'b0};
        end else if (o_busy) begin
            if (i == ITER-1) begin  // we're done
                o_busy <= 0;
                o_valid <= 1;
                o_root <= q_next;
                o_rem <= ac_next[WIDTH+1:2];  // undo final shift
            end else begin  // next iteration
                i <= i + 1;
                x <= x_next;
                ac <= ac_next;
                q <= q_next;
            end
        end
    end

endmodule

