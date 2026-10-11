module DMEM #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  wire        i_Clk,
    input  wire        WE,              //From address_decoder
    input  wire [3:0]  BW,                  //Byte write-enables
    input  wire [ADDR_WIDTH-1:0] A,       //word_index: ALUResultM[11:2]
    input  wire [DATA_WIDTH-1:0] WD,      //Alugned store data
    output reg  [DATA_WIDTH-1:0] RD       //Registered read data (valid in WB)
);

    (* ramstyle = "M10K"  *) reg [DATA_WIDTH-1:0] RAM [0:(2**ADDR_WIDTH)-1]; 

    integer i;
    initial begin
        for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
            RAM[i] = 32'h00000000;
        end
    end

    //Sequential Write & Synchronous Read
    always @(posedge i_Clk) begin
        if (WE) begin
            if (BW[0]) RAM[A][7:0] <= WD[7:0];
            if (BW[1]) RAM[A][15:8] <= WD[15:8];
            if (BW[2]) RAM[A][23:16] <= WD[23:16];
            if (BW[3]) RAM[A][31:24] <= WD[31:24];
        end
        RD <= RAM[A];
    end
endmodule