module Register_PC (
    input           i_Clk,
    input           i_Rst,
    input           StallF,
    input   [31:0]  PC_next,
    output reg [31:0]  PCF
);

    //use  = when always @(*) 
    //use <= when always @(posedge i_Clk)
    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            PCF <= 32'h00000000; // Force PC to boot address
        end else if (StallF) begin
            PCF <= PCF;
        end else begin
            PCF <= PC_next; 
        end
    end
endmodule