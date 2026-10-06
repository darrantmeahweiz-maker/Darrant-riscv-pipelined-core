module MULT(
    input wire [1:0]  MUL_Control,
    input wire [31:0] SrcA,
    input wire [31:0] SrcB, 
    output reg [31:0] MUL_Result
);

    wire [63:0] signed_A     = {{32{SrcA[31]}},SrcA};
    wire [63:0] signed_B     = {{32{SrcB[31]}},SrcB};
    wire [63:0] unsigned_A   = {32'h00000000,SrcA};
    wire [63:0] unsigned_B   = {32'h00000000,SrcB};

    wire [63:0] MULH_out = signed_A * signed_B;         //signed*signed
    wire [63:0] MULHSU_out = signed_A * unsigned_B;     //signed*unsigned
    wire [63:0] MULHU_out = unsigned_A * unsigned_B;    //unsigned*unsigned

    always @(*) begin
        case (MUL_Control)
            2'b00: MUL_Result = MULH_out[31:0];     //MUL
            2'b01: MUL_Result = MULH_out[63:32];    //MULH
            2'b10: MUL_Result = MULHSU_out[63:32];  //MULHSU
            2'b11: MUL_Result = MULHU_out[63:32];   //MULHU
            default: MUL_Result = 32'h00000000;
        endcase
    end
endmodule