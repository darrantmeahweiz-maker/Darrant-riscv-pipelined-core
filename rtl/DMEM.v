module DMEM (
    input  wire        i_Clk,
    input  wire        WE, // MemWriteM --> address_decoder  --> DMEM
    input  wire        OE, // Output enable
    input  wire [3:0]  BW, // Byte-enables funct3D --> EX/MEM --> funct3E --> MEM/WB --> funct3M --> LSU --> DMEM
    input  wire [31:0] A,
    input  wire [31:0] WD,
    output reg  [31:0] RD
);

    reg [31:0] RAM [0:1023]; // 4KB (1024 words x 32 bits)

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            RAM[i] = 32'h00000000;
        end
    end

    // 2**10 = 1024 --> [9:0]
    // Map 0x1001_0000 --> index 0, and divide by 4 for word alignment
    wire [9:0] word_index = (A - 32'h10010000) >> 2;

    // Sequential Write Logic (Byte-Enable Masking)
    always @(posedge i_Clk) begin
        if (WE) begin
            RAM[word_index] <= {
                BW[3] ? WD[31:24] : RAM[word_index][31:24],
                BW[2] ? WD[23:16] : RAM[word_index][23:16],
                BW[1] ? WD[15:8]  : RAM[word_index][15:8],
                BW[0] ? WD[7:0]   : RAM[word_index][7:0]
            };
        end
    end

    // Combinational Read Logic
    always @(*) begin
        if (OE) begin
            RD = RAM[word_index];
        end else begin
            RD = 32'h00000000;
        end
    end
endmodule