module reset(
    input wire onfi_clk,
    output reg onfi_cen,
    output reg onfi_cle,
    output reg onfi_ale,
    output reg onfi_wen,
    output reg onfi_dqs_en,
    output reg [31:0] onfi_dq_o,
    output reg onfi_dq_en
);

initial begin
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 0;
    onfi_dqs_en = 0;
    onfi_dq_o = 32'h00;
    onfi_dq_en = 0;
end

reg [1:0] state = 0;

always @(negedge onfi_clk) begin
    case (state)
        0: begin
            onfi_cen = 0;
            onfi_cle = 0;
            onfi_ale = 0;
            onfi_wen = 1;
            onfi_dqs_en = 0;
            state = state + 1;
        end
        1: begin
            onfi_cle = 1;
            onfi_dq_o = 32'hFF;
            onfi_dq_en = 1;
            state = state + 1;
        end
        2: begin
            onfi_cle = 0;
            onfi_dq_en = 0;
            state = state + 1;
        end
        3: begin
            onfi_cen = 1;
            state = 0;
        end
        default: begin
            state = 0;
        end
    endcase
end

endmodule
