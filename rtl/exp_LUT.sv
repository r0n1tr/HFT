module exp_LUT #
(
    parameter int LUT_SIZE = 101,
    parameter int DATA_WIDTH = 32,
    parameter int FRACTION_WIDTH = 16 // Number of fractional bits
)
(
    input logic [DATA_WIDTH-1:0] argument,
    input logic i_clk,
    output logic [DATA_WIDTH-1:0] exp_output
);

    // Fixed-point LUT values with FRACTION_WIDTH fractional bits
    logic [DATA_WIDTH-1:0] lut_values [0:LUT_SIZE-1];
    int lower_index;
    logic [DATA_WIDTH-1:0] floor, ceil, fraction, exp_result;
    logic [DATA_WIDTH-1:0] exp_output_temp;

    // Initial block to initialize the LUT
    initial begin
        lut_values[0] = 32'h00010000;      // e^0 = 1.000000 (1 << 16)
        lut_values[1] = 32'h00010A40;      // e^0.04 ≈ 1.040810
        lut_values[2] = 32'h0001160F;      // e^0.08 ≈ 1.083287
        lut_values[3] = 32'h00012449;      // e^0.12 ≈ 1.127497
        lut_values[4] = 32'h0001350F;      // e^0.16 ≈ 1.173511
        lut_values[5] = 32'h00014949;      // e^0.20 ≈ 1.221403
        lut_values[6] = 32'h00016020;      // e^0.24 ≈ 1.271250
        lut_values[7] = 32'h00017AA4;      // e^0.28 ≈ 1.323130
        lut_values[8] = 32'h000198E1;      // e^0.32 ≈ 1.377128
        lut_values[9] = 32'h0001BAF3;      // e^0.36 ≈ 1.433329
        lut_values[10] = 32'h0001E0F3;     // e^0.40 ≈ 1.491825
        // Initialize other values up to e^4 ...
        lut_values[100] = 32'h00372EAD;   // e^4 ≈ 54.598150
    end

    // Always_comb block for LUT access with interpolation

    always_ff@(posedge i_clk) begin
        // Initialize all variables to avoid latches

        // Use integer arithmetic for fixed-point interpolation
        if(argument < 32'h00010000) begin
            exp_result <= lut_values[0];
        end
        else if(argument > 32'h00040000) begin
            exp_result <= lut_values[100];
        end
        else begin
            lower_index <= (argument - 32'h00010000) >> (FRACTION_WIDTH - 2); // Calculate lower index
            fraction <= (argument - (lower_index << (FRACTION_WIDTH - 2))) << 2; // Calculate fraction part

            if (lower_index == LUT_SIZE - 1) begin
                exp_result <= lut_values[lower_index];
            end
            else begin
                floor <= lut_values[lower_index];
                ceil <= lut_values[lower_index + 1];
                exp_result <= floor + ((ceil - floor) * fraction >> FRACTION_WIDTH);
            end
        end

        // Assign the temporary output to the final output
        exp_output_temp <= exp_result;
    end

    assign exp_output = exp_output_temp;

endmodule
