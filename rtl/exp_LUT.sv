// lut of 10k entries, -1 to 1 

// fixed point numbers - 32 integers // fixed point 32.32





module exp_LUT #
(
    parameter array_size = 1_000_000
)
(
    input logic i_clk,
    input logic signed [34:0] input_value, // q1.34 fixed-point input
    output logic [63:0] exp_value // Scaled exponential value output
);
    
    logic [63:0] lut [array_size-1:0];

    // Read the exponential values from the memory file
    initial begin
        $readmemh("/home/ronit/HFT/HFT/rtl/exp_values.mem", lut);
    end

    // Calculate the index based on the input_value
    logic [19:0] index; // 20-bit index to cover array_size (log2(1000000) = ~20 bits)
    always_comb begin
        // Scale and clamp the input_value to the range of indices
        if (input_value < 35'sh0C00000000) // -1.0 in q1.34
            index = 0;
        else if (input_value > 35'sh0400000000) // 1.0 in q1.34
            index = array_size-1;
        else begin
            // Equivalent of (input_value + 1.0) * (array_size-1) / 2.0 in q1.34
            logic signed [68:0] scaled_value; // 69-bit value to accommodate the calculation
            scaled_value = (input_value + 35'sd17179869184) * (array_size-1);
            index = scaled_value[68:49]; // Division by 2^34 and truncation to 20 bits
        end
    end

    // Lookup the exponential value and multiply by base_order
    assign exp_value = lut[index];

endmodule
