`include "../rtl/exp_lut.sv"

module order_quantity 
(
   input logic i_clk,
   input logic signed [63:0] i_inventory_state,
   
   output logic [63:0] o_order_out,
   output logic [31:0] o_order_filter
);

   localparam shape_parameter = 0.5;
   
   logic [63:0] temp;
   logic [127:0] mult; 

   // Instantiate exp_lut
   exp_lut my_exp_lut (
      .i_clk(i_clk),
      .input_value(shape_parameter * i_inventory_state),
      .exp_value(temp)
   );

   // Perform multiplication with continuous assignment
   assign mult = 64'h0000006400000000 * temp; // min order quant = 100

   // Extract desired bits from mult and assign to o_order_out
   assign o_order_out = mult[95:32]; // Assuming you want a 64-bit output
   assign o_order_filter = o_order_out[63:32];

endmodule
