`timescale 1ns / 1ps
module get_feature
#(
    parameter ONFI_FRE = 200
)
(
    input wire [31:0] addr,
    input wire onfi_clk,
    output reg [31:0] data,
    output reg onfi_ale,
    output reg onfi_cen,
    output reg onfi_cle,
    output reg onfi_dq,
    output reg onfi_dq_en,
    output reg [31:0] onfi_dq_o,
    input wire onfi_dqs,
    output reg onfi_dqs_en,
    output reg onfi_wen
);
    reg [3:0] state=0;
    always@(negedge onfi_clk) begin 
        case(state)
            0: begin
                onfi_cen = 0;
                onfi_cle = 0;
                onfi_ale = 0;
                onfi_wen = 1;
                onfi_dqs_en = 0;
                state = state + 1;
            end
            1: begin//command
                onfi_cle = 1;
                onfi_dq_o = 32'hEE;
                onfi_dq_en = 1;
                state = state + 1;
            end
            2: begin//addr
                onfi_cle = 0;
                onfi_ale = 1;
                onfi_dq_o = addr;
                state = state + 1;
            end
            3: begin//data
                onfi_ale = 0;
                onfi_dq_en = 0;
                onfi_wen = 0;
                state = state + 1;
            end
            4: begin
                onfi_cle = 1;
                onfi_ale = 1;
                state = state + 1;
            end
            5: begin
                onfi_cle = 0;
                onfi_ale = 0;
                state = state + 1;
            end
            8: begin
                onfi_cen = 1;
                onfi_cle = 0;
                onfi_ale = 0;
                onfi_wen = 1;
            end
            default: begin
            end

        endcase
    end
    always@(posedge onfi_dqs) begin
        case(state)
        6: begin
            #(500/(ONFI_FRE*2)) data = onfi_dq;//wait 1/4 T to ensure data stability
            state = state + 1;
        end
        endcase
    end
    always@(negedge onfi_dqs) begin
        case(state)
        7: begin
            #(500/(ONFI_FRE*2)) data = onfi_dq;//the same data
            state = state + 1;
        end
        endcase
    end
endmodule
