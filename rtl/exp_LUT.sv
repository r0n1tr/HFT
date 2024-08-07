module exp_LUT #(
    parameter INPUT_WIDTH = 10,  // width of input
    parameter OUTPUT_WIDTH = 16  // width of output
) (
    input  logic i_clk,
    input  logic signed [INPUT_WIDTH-1:0] i_arg,  // fixed-point input in Q1.8 format
    output logic [OUTPUT_WIDTH-1:0] o_result  // fixed-point output in Q8.8 format
);

    // Adjust size according to the number of steps (1024 entries for 10-bit indices)
    logic [15:0] LUT [0:100];

    // Initialize the lookup table from the .mem file
    initial begin
        $readmemh("exp_lut.mem", LUT);
    end

    // Intermediate variable to hold the computed index
    logic [9:0] lut_index;

    // Convert the 10-bit fixed-point input to a 10-bit index
    always_ff @(posedge i_clk) begin
        // Convert Q1.8 input to an index range of 0 to 1023
        lut_index <= i_arg + 10'sh200;  // Offset to make it unsigned (adding 2^9 to shift the range from [-512, 511] to [0, 1023])
        o_result <= LUT[lut_index];
    end

endmodule
