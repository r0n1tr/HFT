////////////////////////////
// key: 
// 'i' input
// 'o' output
// 'w' wire/internal signal
 
module orderBook (
    parameters stock = 4,
    cols = 6; 
    rows = 10;
    regWidth = 64;
    pointer_width = 10;

)
(
    
    input clk,
    input reset_en,
    input write_en, // if write_en is low, then trading logic can access order book
    //input read_en,

    input logic [63:0] stock_symbol, // 1 reg
    input logic [31:0] quantity, // 1 reg
    input logic [31:0] price, // 1 reg
    input logic [63:0] ref_id, // 1 reg
    input logic [7:0] order_type,   // 1 reg

    output logic [31:0] bid_price,
    output logic [31:0] sell_price,
    output logic [31:0] curr_price
)


/////////////////////
// WE NEED SOME ORDER_TYPE MUX TO SET OPERATION SIGNAL

logic [2:0] stock_number = stock_symbol[2:0] // or insert some logic here for concatenation
 
logic [regWidth-1:0] stock1 [0:cols-1][0:rows-1]; // 1000 by 4 matrix of 32bit registers to store relevant information
logic [regWidth-1:0] stock2 [0:cols-1][0:rows-1]; 
logic [regWidth-1:0] stock3 [0:cols-1][0:rows-1];
logic [regWidth-1:0] stock4 [0:cols-1][0:rows-1];

logic [pointer_width-1:0] pointer1 = 0;
logic [pointer_width-1:0] pointer2 = 0;
logic [pointer_width-1:0] pointer3 = 0;
logic [pointer_width-1:0] pointer4 = 0;

// ALTERNATIVE METHOD
// always_ff @(posedge clk) begin
//     if(reset_en) begin
//         pointer1 <= 0;
//         pointer2 <= 0;
//         pointer3 <= 0;
//         pointer4 <= 0;
//         for(int i = 0; i < rows-1; i++) begin
//             for(int j = 0; j < cols-1; j++) begin
//                 stock1[i][j] <= 32'b0;
//                 stock2[i][j] <= 32'b0;
//                 stock3[i][j] <= 32'b0;
//                 stock4[i][j] <= 32'b0;
//             end
//         end
//     end
//     else if (write_en) begin
//         // code simply overwrites elements rather than deleting
//         case (stock_symbol)
//             64'h00: begin //AAPL
//                 if (condition) begin
//                     pass
//                 end
//                 stock1[pointer1][0] <= stock_symbol;
//                 stock1[pointer1][1] <= quantity;
//                 stock1[pointer1][2] <= price;
//                 stock1[pointer1][3] <= ref_id;
//                 stock1[pointer1][4] <= order_type;
//                 pointer1 <= (pointer1 + 1) % rows; // implements circular buffer. pointer increment up for recent trades
//             end
//             64'h01: begin //MSFT
//                 stock2[pointer2][0] <= stock_symbol;
//                 stock2[pointer2][1] <= quantity;
//                 stock2[pointer2][2] <= price;
//                 stock2[pointer2][3] <= ref_id;
//                 stock2[pointer2][4] <= order_type;
//                 pointer2 <= (pointer2 + 1) % rows;
//             end         
//             64'h10: begin // NVDA
//                 stock3[pointer3][0] <= stock_symbol;
//                 stock3[pointer3][1] <= quantity;
//                 stock3[pointer3][2] <= price;
//                 stock3[pointer3][3] <= ref_id;
//                 stock3[pointer3][4] <= order_type;
//                 pointer3 <= (pointer3 + 1) % rows;
//             end     
//             64'h11: begin // BTC
//                 stock4[pointer4][0] <= stock_symbol;
//                 stock4[pointer4][1] <= quantity;
//                 stock4[pointer4][2] <= price;
//                 stock4[pointer4][3] <= ref_id;
//                 stock4[pointer4][4] <= order_type;
//                 pointer4 <= (pointer4 + 1) % rows;
//             end        
//             default:       // do nothing  
//         endcase
//     end
// end

always_ff @(posedge clk) begin
    if(reset_en) begin
        pointer1 <= 0;
        pointer2 <= 0;
        pointer3 <= 0;
        pointer4 <= 0;
        for(int i = 0; i < rows-1; i++) begin
            for(int j = 0; j < cols-1; j++) begin
                stock1[i][j] <= 32'b0;
                stock2[i][j] <= 32'b0;
                stock3[i][j] <= 32'b0;
                stock4[i][j] <= 32'b0;
            end
        end
    end
    else if (write_en) begin
        // code simply overwrites elements rather than deleting
        case (order_type)
            add_order: begin
                stock{stock_number}[pointer{stock_number}][0] <= stock_symbol;
                stock{stock_number}[pointer{stock_number}][1] <= quantity;
                stock{stock_number}[pointer{stock_number}][2] <= price;
                stock{stock_number}[pointer{stock_number}][3] <= ref_id;
                stock{stock_number}[pointer{stock_number}][4] <= order_type;
                pointer{stock_number} <= (pointer{stock_number} + 1) % rows; // implements circular buffer. pointer increment up for recent trades
            end
            modify_order: 
                logic found;
                int found_index;
                found = 0;
                found_index = -1;
                for (int i = 0; i < rows-1; i++) begin
                        if (stock{stock_number}[i][3] == ref_id) begin
                            found = 1;
                            found_index = i;
                        end
                    end    
                // replace
                if (replace_en && found) begin
                    stock{stock_number}[found_index][1] <= quantity; // dont require any other changes
                    stock{stock_number}[found_index][2] <= price;
                    stock{stock_number}[found_index][4] <= order_type;
                end 
                // delete
                else if (delete_en && found) begin
                        for (int i = found_index; i < rows - 1; i++) begin
                            stock{stock_number}[i] <= stock{stock_number}[i + 1];
                        end
                        stock{stock_number}[rows-1][0] <= 64'b0;
                        stock{stock_number}[rows-1][1] <= 64'b0;
                        stock{stock_number}[rows-1][2] <= 64'b0;
                        stock{stock_number}[rows-1][3] <= 64'b0;
                        stock{stock_number}[rows-1][4] <= 64'b0;
                        pointer{stock_number} <= (pointer{stock_number} - 1) % rows;
                end
            default:       // do nothing  
        endcase
    end
end
endmodule
