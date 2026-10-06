module CRC(
    input wire [1:0] CRC_Control,
    input wire [31:0] SrcA,
    input wire [31:0] SrcB, 
    output reg [31:0] CRC_Result
);

    // CRC8 logic 
    function [7:0] CRC8 (input [31:0] data, input [31:0] seed); //8'h07
        reg [7:0] crc;
        reg inv;
        integer i;
        begin
            crc = seed[7:0];
            for (i=31; i>=0; i = i -1) begin
                inv = crc[7] ^ data[i];
                crc = (crc << 1) ^ ({8{inv}} & 8'h07);
            end
            CRC8 = crc;
        end
    endfunction

    // CRC16 logic 
    function [15:0] CRC16 (input [31:0] data, input [31:0] seed); //16'h8005
        reg [15:0] crc;
        reg inv;
        integer i;
        begin
            crc = seed[15:0];
            for (i=31; i>=0; i = i -1) begin
                inv = crc[15] ^ data[i];
                crc = (crc << 1) ^ ({16{inv}} & 16'h8005);
            end
            CRC16 = crc;
        end
    endfunction

    // CRC32 logic 
    function [31:0] CRC32 (input [31:0] data, input [31:0] seed); //32'h04C11DB7
        reg [31:0] crc;
        reg inv;
        integer i;
        begin
            crc = seed;
            for (i=31; i>=0; i = i -1) begin
                inv = crc[31] ^ data[i];
                crc = (crc << 1) ^ ({32{inv}} & 32'h04C11DB7);
            end
            CRC32 = crc;
        end
    endfunction

    always @(*) begin 
        case (CRC_Control)
            2'b00: CRC_Result = {24'h000000, CRC8(SrcA, SrcB)};
            2'b01: CRC_Result = {16'h0000, CRC16(SrcA, SrcB)};
            2'b10: CRC_Result = CRC32(SrcA, SrcB);
            default: CRC_Result = 32'h00000000;
        endcase
    end
endmodule