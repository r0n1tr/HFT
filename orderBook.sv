module orderBook (
    parameters stock = 4,
    cols = 3;
    rows = 10;
    regWidth = 32;

)
(
    input logic [31:0] incoming_trade [0:2],
    input logic [1:0] select_stock
    output logic [31:0] finalStock [0:2][0:9];
)

logic [31:0] stock2 [0:2][0:9];
logic [31:0] stock3 [0:2][0:9];
logic [31:0] stock4 [0:2][0:9];
logic [31:0] stock1 [0:2][0:9];

logic stockSymbol = [0]incomingTrade[31:30];

logic pointerStock1;
logic startPointerStock1;
logic endPointerStock1;

logic pointerStock2;
logic startPointerStock2;
logic endPointerStock2;

logic pointerStock3;
logic startPointerStock3;
logic endPointerStock3;

logic pointerStock4;
logic startPointerStock4;
logic endPointerStock4;

always_comb begin
    case(stockSymbol)
        2'b00: //BTC
        2'b01: //ETH
        2'b10: //BNB
        2'b11: //SOL
        default: ;
    endcase

end

endmodule
