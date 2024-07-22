// task read;
//     input [31:0] addr;
//     input [31:0] length;//transfer length / 2
//     output [9*32*32-1:0] data;//data from high to low, like bid endian
// begin: block2
//     integer pos;
//     pos= 0;
//     data = 0;
//     @(negedge onfi_clk);
//     onfi_cen = 0;
//     onfi_cle = 0;
//     onfi_ale = 0;
//     onfi_wen = 1;
//     onfi_dqs_en = 0;
//     @(negedge onfi_clk);//command
//     onfi_cle = 1;
//     onfi_dq_o = 32'h00;
//     onfi_dq_en = 1;
//     @(negedge onfi_clk);//addr
//     onfi_cle = 0;
//     onfi_ale = 1;
//     onfi_dq_o = addr;
//     @(negedge onfi_clk);//length
//     onfi_cle = 0;
//     onfi_ale = 1;
//     onfi_dq_o = length;
//     @(negedge onfi_clk);//data
//     onfi_ale = 0;
//     onfi_dq_en = 0;
//     onfi_wen = 0;
//     fork
//     begin
//         repeat(length) begin
//             @(negedge onfi_clk);
//             onfi_cle = 1;
//             onfi_ale = 1;
//         end
//         @(negedge onfi_clk);
//         onfi_cle = 0;
//         onfi_ale = 0;
//     end
//     begin
//         @(negedge onfi_clk);
//         @(negedge onfi_clk);
//         repeat(length) begin
//             @(posedge onfi_dqs);
//             #(500/(ONFI_FRE*2)) data = data | ({9184'b0, onfi_dq} << (pos * 32));//wait 1/4 T to ensure data stability
//             pos = pos + 1;
//             @(negedge onfi_dqs);
//             #(500/(ONFI_FRE*2)) data = data | ({9184'b0, onfi_dq} << (pos * 32));//the same data
//             pos = pos + 1;
//         end
//     end
//     join
//     @(negedge onfi_clk);
//     onfi_cen = 1;
//     onfi_cle = 0;
//     onfi_ale = 0;
//     onfi_wen = 1;
// end
// endtask