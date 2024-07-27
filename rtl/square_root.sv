module square_root #(
    parameter WIDTH=32,  // width of radicand
    parameter FBITS=16   // fractional bits (for fixed point)
    ) (
    input wire logic i_clk,
    input wire logic i_start,             // start signal
    output     logic o_busy,              // calculation in progress
    output     logic o_valid,             // root and rem are valid
    input wire logic [WIDTH-1:0] i_rad,   // radicand
    output     logic [WIDTH-1:0] o_root,  // root
    output     logic [WIDTH-1:0] o_rem    // remainder
    );

    logic [WIDTH-1:0] x, x_next;    // radicand copy
    logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
    logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
    logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)

    localparam ITER = (WIDTH+FBITS) >> 1;  // iterations are half radicand+fbits width
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
            /* verilator lint_off WIDTH */
            if (i == ITER-1) begin  // we're done
            /* verilator lint_on WIDTH */
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
