module Control_Unit (
    //Inputs from instruction (Decode stage)
    input       [6:0]   op,
    input       [2:0]   funct3,
    input               funct7b5,   //only use bit 30 of the instruction

    //Output to pipelined register
    output reg          RegWriteD,
    output reg  [1:0]   ResultSrcD,
    output reg          MemWriteD,
    output reg          JumpD,
    output reg          BranchD,
    output reg  [3:0]   ALUControlD,
    output reg          ALUSrcD,
    output reg          ALUSrcA_D,  // NEW: To route PC into ALU for AUIPC
    output reg  [2:0]   ImmSrcD     // Removed the trailing comma here!
);

    //Combinational logic
    always @(*) begin
        //Set default values (Added the missing 'D' to all of these)
        RegWriteD   = 1'b0;
        ResultSrcD  = 2'b00;
        MemWriteD   = 1'b0;
        JumpD       = 1'b0;
        BranchD     = 1'b0;
        ALUControlD = 4'b0000;
        ALUSrcD     = 1'b0;
        ALUSrcA_D   = 1'b0; // Default: use Register 1 for ALU input A
        ImmSrcD     = 3'b000;

        //Decode the Opcode
        case (op)
            // ----------------------------------------------------
            // R-type & I-type (ALU operations)
            // ----------------------------------------------------
            7'b0110011, 7'b0010011: begin   
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b00;    //ALUResult
                ALUSrcD     = (op==7'b0010011)? 1'b1: 1'b0; //I-type is one while R-type is zero
                ImmSrcD     = 3'b000;
                case (funct3)
                    3'b000: begin
                        if (funct7b5 == 1'b1 && op ==7'b0110011) begin
                            ALUControlD = 4'h2; //sub (note:i-type haven't sub)
                        end else begin
                            ALUControlD = 4'h1; //add & addi
                        end
                    end
                    3'b001: ALUControlD = 4'h6; //sll & slli
                    3'b010: ALUControlD = 4'h9; //slt & slti
                    3'b011: ALUControlD = 4'hA; //sltu & sltiu
                    3'b100: ALUControlD = 4'h5; //xor & xori
                    3'b101: begin
                        if (funct7b5 == 1'b1) begin
                            ALUControlD = 4'h8; //sra & srai
                        end else begin
                            ALUControlD = 4'h7; //srl & srli
                        end
                    end
                    3'b110: ALUControlD = 4'h4; //or & ori
                    3'b111: ALUControlD = 4'h3; //and & andi
                    default: ALUControlD = 4'h0;
                endcase
            end

            // ----------------------------------------------------
            // I-type (Load)
            // ----------------------------------------------------
            7'b0000011: begin               
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b01;    //ReadData from Memory
                ALUSrcD     = 1'b1;     //immediate for offset
                ImmSrcD     = 3'b000;
                ALUControlD = 4'h1;     //Add (base + offset)
            end

            // ----------------------------------------------------
            // S-type (Store)
            // ----------------------------------------------------
            7'b0100011: begin               
                MemWriteD   = 1'b1;
                ALUSrcD     = 1'b1;
                ImmSrcD     = 3'b001;
                ALUControlD = 4'h1;     //Add  
            end

            // ----------------------------------------------------
            // B-type (Branch)
            // ----------------------------------------------------
            7'b1100011: begin               
                ALUSrcD     = 1'b0;     //compare rs1 and rs2
                ImmSrcD     = 3'b010;   
                BranchD     = 1'b1;
                case(funct3)
                    3'b000: ALUControlD = 4'h2; // BEQ  (We can reuse SUB, Zero is 1 if A==B)
                    3'b001: ALUControlD = 4'hB; // BNE
                    3'b100: ALUControlD = 4'hC; // BLT
                    3'b101: ALUControlD = 4'hD; // BGE
                    3'b110: ALUControlD = 4'hE; // BLTU
                    3'b111: ALUControlD = 4'hF; // BGEU
                    default: ALUControlD = 4'h0;
                endcase
            end

            // ----------------------------------------------------
            // J-type (JAL)
            // ----------------------------------------------------
            7'b1101111: begin               
                RegWriteD   = 1'b1;
                JumpD       = 1'b1;
                ResultSrcD  = 2'b10;        //save PC+4 to rd
                ImmSrcD     = 3'b011;       //J-type immediate formatting
            end

            // ----------------------------------------------------
            // I-type (JALR)
            // ----------------------------------------------------
            7'b1100111: begin               
                RegWriteD   = 1'b1;
                JumpD       = 1'b1;         //it is jump
                ResultSrcD  = 2'b10;        //save PC+4 to rd
                ImmSrcD     = 3'b000;       //I-type immediate formatting
                ALUControlD = 4'h1;         //add for jump target
                ALUSrcD     = 1'b1;         //add immediate to Rs1
            end

            // ----------------------------------------------------
            // U-type (LUI - Load Upper Immediate)
            // ----------------------------------------------------
            7'b0110111: begin   
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b00;        //ALUResult
                ImmSrcD     = 3'b100;       //U-type immediate formating
                ALUControlD = 4'h0;         //PASS (ALUResult = SrcB)
                ALUSrcD     = 1'b1;         //Pass the immediate into ALU
            end

            // ----------------------------------------------------
            // U-type (AUIPC - Add Upper Immediate to PC)
            // ----------------------------------------------------
            7'b0010111: begin 
                RegWriteD   = 1'b1;
                ALUSrcA_D   = 1'b1;         // NEW: Tell ALU to read PC instead of Rs1
                ALUSrcD     = 1'b1;         // Tell ALU to read Immediate instead of Rs2
                ImmSrcD     = 3'b100;       // U-type immediate formatting
                ALUControlD = 4'h1;         // ADD (PC + Immediate)
                ResultSrcD  = 2'b00;        // Normal ALU Result
            end

            // ---------------------------------------------------- 
            // System (ECALL/EBREAK) & Fence
            // ----------------------------------------------------
            7'b1110011,7'b0001111: begin               
            end

            default: begin
            end
        endcase
    end
endmodule