module set_feature(
  input wire onfi_clk,
  input reg [31:0] addr,
  input reg [31:0] data,
  output reg onfi_cen,
  output reg onfi_cen,
  output reg onfi_cle,
  output reg onfi_ale,
  output reg onfi_wen,
  output reg onfi_dqs_en,
  output reg onfi_dq_o
);
  reg [2:0] state = 0;

  initial begin
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 0;
    onfi_dqs_en = 0;
    onfi_dq_o = 32'h00;
  end

  always@(negedge onfi_clk) begin
    case(state)
    0:
      begin
        onfi_cen = 0;
        onfi_cle = 0;
        onfi_ale = 0;
        onfi_wen = 1;
        onfi_dqs_en = 0;
        state = state + 1;
      end
    1:
      begin
        onfi_cle = 1;
        onfi_dq_o = 32'hEF;
        onfi_dq_en = 1;
        state = state + 1;
      end
    2:
      begin
        onfi_cle = 0;
        onfi_ale = 1;
        onfi_dq_o = addr;
        state = state + 1;
      end
    3:  
      begin
        onfi_ale = 0;
        onfi_dq_en = 0;
        state = state+1;
      end
    4:
      begin
        onfi_cen = 1;
        onfi_wen = 0;
        onfi_dq_o = data;
        onfi_dq_en = 1;
        state = 0;
      end
    5:
      begin
        onfi_dq_en = 0;
        state = state + 1;
      end
    default:
      begin
        state = 0;
      end
  endcase
  end

  always@(posedge onfi_clk) begin
    case(state)
      
    endcase
  end
endmodule