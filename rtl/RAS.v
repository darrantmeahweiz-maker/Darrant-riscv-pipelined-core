module RAS (
    input           i_clk,
    input           i_rst,
    input           Push_Enable,
    input   [31:0]  Push_Data,
    input           Pop_Enable,
    output  [31:0]  Predicted_PC
);

    reg [31:0]  stack [0:7];    // 8-entry deep stack
    reg [2:0]   sp;             // 3-bit Stack Pointer (0 to 7)

    always @(posedge i_clk) begin 
        if (i_rst) begin
            sp <= 3'b000;
        end else if (Push_Enable) begin 
            stack[sp] <= Push_Data;     
            sp <= sp + 1;
        end else if (Pop_Enable) begin
            sp <= sp - 1;
        end
    end

    // Asynchronously read top of stack
    assign Predicted_PC = stack[sp-1];
endmodule