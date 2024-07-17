module parser(
    parameter regWidth = 32

)
(
    input logic [regWidth-1:0] reg1,
    input logic [regWidth-1:0] reg2,
    input logic [regWidth-1:0] reg3
    output logic [1:0] stockSymbol,
    output logic [2:0] tradeFunction,
    output logic [7:0] quantity,
    output logic [9:0] currentPrice,
    output logic [20:0] dateStamp,
    output logic [10:0] timeStamp,

    output logic [9:0] buyPrice,
    output logic [9:0] sellPrice,

)

assign stockSymbol = reg1[31:30];
assign tradeFunction = reg1[29:27];
assign quantity = reg1[26:19];
assign price = reg1[18:9];

assign dateStamp = reg2[31:11];
assign timeStamp = reg2[10:0];

assign buyPrice = reg3[31:22];
assign sellPrice = reg3[21:12];


endmodule



