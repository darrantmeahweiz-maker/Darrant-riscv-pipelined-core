module ALU (
    input wire [31:0]   SrcAE,
    input wire [31:0]   SrcBE,
    input wire [3:0]    ALUControlE,
    output reg [31:0]   ALUResultE,
    output              o_Zero //to Control_Unit, then to AND gate
);
    localparam c_ALU_OP_PASS = 4'h0;
    localparam c_ALU_OP_ADD  = 4'h1;
    localparam c_ALU_OP_SUB  = 4'h2;
    localparam c_ALU_OP_AND  = 4'h3;
    localparam c_ALU_OP_OR   = 4'h4;
    localparam c_ALU_OP_XOR  = 4'h5;
    localparam c_ALU_OP_SLL  = 4'h6;
    localparam c_ALU_OP_SRL  = 4'h7;
    localparam c_ALU_OP_SRA  = 4'h8;
    localparam c_ALU_OP_SLT  = 4'h9;
    localparam c_ALU_OP_SLTU = 4'hA;
    localparam c_ALU_OP_BNE  = 4'hB;
    localparam c_ALU_OP_BLT  = 4'hC;
    localparam c_ALU_OP_BGE  = 4'hD;
    localparam c_ALU_OP_BLTU = 4'hE;
    localparam c_ALU_OP_BGEU = 4'hF;
 
    // o_Zero becomes a "Branch Condition Met" flag for branch operations
    assign o_Zero = (ALUControlE == c_ALU_OP_BNE)  ? (SrcAE != SrcBE) :
                    (ALUControlE == c_ALU_OP_BLT)  ? ($signed(SrcAE) < $signed(SrcBE)) :
                    (ALUControlE == c_ALU_OP_BGE)  ? ($signed(SrcAE) >= $signed(SrcBE)) :
                    (ALUControlE == c_ALU_OP_BLTU) ? (SrcAE < SrcBE) :
                    (ALUControlE == c_ALU_OP_BGEU) ? (SrcAE >= SrcBE) :
                    (ALUResultE == 32'b0); // Default for ADD, SUB, BEQ, and logical ops
  
    always @ (*) begin
        case (ALUControlE)
            c_ALU_OP_PASS: ALUResultE = SrcBE;
            c_ALU_OP_ADD:  ALUResultE = SrcAE + SrcBE;
            c_ALU_OP_SUB:  ALUResultE = SrcAE - SrcBE;
            c_ALU_OP_AND:  ALUResultE = SrcAE & SrcBE;
            c_ALU_OP_OR:   ALUResultE = SrcAE | SrcBE;
            c_ALU_OP_XOR:  ALUResultE = SrcAE ^ SrcBE;
            c_ALU_OP_SLL:  ALUResultE = SrcAE << SrcBE[4:0];
            c_ALU_OP_SRL:  ALUResultE = SrcAE >> SrcBE[4:0];
            c_ALU_OP_SRA:  ALUResultE = $signed(SrcAE) >>> SrcBE[4:0];
            c_ALU_OP_SLT:   ALUResultE = ($signed(SrcAE) < $signed(SrcBE)) ? 32'd1 : 32'd0;
            c_ALU_OP_SLTU:  ALUResultE = ($unsigned(SrcAE) < $unsigned(SrcBE)) ? 32'd1 : 32'd0;
            default:       ALUResultE = 32'b0;
        endcase
    end
endmodule

