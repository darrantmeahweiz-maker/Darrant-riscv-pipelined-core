module LSU (
    // MEM Stage (Store path)
    input       [2:0]   funct3M,
    input       [1:0]   ByteOffsetM,            // ALUResultM[1:0]   
    input       [31:0]  WriteDataM,                 
    output reg  [3:0]   BW,                 
    output reg  [31:0]  Formatted_WriteDataM,

    // WB Stage (Load path)
    input       [2:0]   funct3W,
    input       [1:0]   ByteOffsetW,            // ALUResultW[1:0]
    input       [31:0]  Raw_ReadDataW,          // Directly from DMEM.RD
    output reg  [31:0]  Formatted_ReadDataW
);

always @(*) begin
    BW = 4'b0000;
    Formatted_WriteDataM = WriteDataM;

    case (funct3M[1:0])
        2'b00: begin
            case (ByteOffsetM)       //sb, save byte
                2'b00: begin BW = 4'b0001; Formatted_WriteDataM = {24'b0, WriteDataM[7:0]}; end 
                2'b01: begin BW = 4'b0010; Formatted_WriteDataM = {16'b0, WriteDataM[7:0], 8'b0}; end
                2'b10: begin BW = 4'b0100; Formatted_WriteDataM = {8'b0, WriteDataM[7:0], 16'b0}; end
                2'b11: begin BW = 4'b1000; Formatted_WriteDataM = {WriteDataM[7:0],24'b0}; end
            endcase
        end
        2'b01: begin
            case (ByteOffsetM[1])    //sh, save halfword
                1'b0: begin BW = 4'b0011; Formatted_WriteDataM = {16'b0,WriteDataM[15:0]}; end
                1'b1: begin BW = 4'b1100; Formatted_WriteDataM = {WriteDataM[15:0],16'b0}; end
            endcase
        end
        2'b10: begin
            BW = 4'b1111;           //sw, save word
            Formatted_WriteDataM = WriteDataM;
        end
        default: begin
            BW = 4'b0000;
            Formatted_WriteDataM = WriteDataM;
        end
    endcase

    //Read path
    case (funct3W)
        3'b000: begin   //lb (load byte, sign-extended)
            case (ByteOffsetW)
                2'b00: Formatted_ReadDataW = {{24{Raw_ReadDataW[7]}}, Raw_ReadDataW[7:0]};
                2'b01: Formatted_ReadDataW = {{24{Raw_ReadDataW[15]}}, Raw_ReadDataW[15:8]};
                2'b10: Formatted_ReadDataW = {{24{Raw_ReadDataW[23]}}, Raw_ReadDataW[23:16]};
                2'b11: Formatted_ReadDataW = {{24{Raw_ReadDataW[31]}}, Raw_ReadDataW[31:24]};
            endcase
        end
        3'b100: begin   //lbu (load byte unsigned, zero-extended)
            case (ByteOffsetW)
                2'b00: Formatted_ReadDataW = {24'b0, Raw_ReadDataW[7:0]};
                2'b01: Formatted_ReadDataW = {24'b0, Raw_ReadDataW[15:8]};
                2'b10: Formatted_ReadDataW = {24'b0, Raw_ReadDataW[23:16]};
                2'b11: Formatted_ReadDataW = {24'b0, Raw_ReadDataW[31:24]};
            endcase
        end
        3'b001: begin   //lh (load halfword, sign-extended)
            case (ByteOffsetW[1])
                1'b0: Formatted_ReadDataW = {{16{Raw_ReadDataW[15]}}, Raw_ReadDataW[15:0]};
                1'b1: Formatted_ReadDataW = {{16{Raw_ReadDataW[31]}}, Raw_ReadDataW[31:16]};
            endcase
        end
        3'b101: begin   //lhu (Load Halfword Unsigned, Zero-Extended)
            case (ByteOffsetW[1])
                1'b0: Formatted_ReadDataW = {16'b0, Raw_ReadDataW[15:0]};
                1'b1: Formatted_ReadDataW = {16'b0, Raw_ReadDataW[31:16]};
            endcase
        end
        3'b010: begin   //lw (load word)
            Formatted_ReadDataW = Raw_ReadDataW;
        end
        default: begin
            Formatted_ReadDataW = Raw_ReadDataW;
        end
    endcase
end
endmodule