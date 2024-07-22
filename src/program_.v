// task program_;
//     input [31:0] addr;
//     input [31:0] length;//transfer length / 2
//     input [9*32*32-1:0] data;//data from low to high, like little endian
// begin:block1
//     reg [9*32*32-1:0] data_tmp1;
//     reg [9*32*32-1:0] data_tmp2;
//     @(negedge onfi_clk);
//     onfi_cen = 0;
//     onfi_cle = 0;
//     onfi_ale = 0;
//     onfi_wen = 1;
//     onfi_dqs_en = 0;
//     @(negedge onfi_clk);//command
//     onfi_cle = 1;
//     onfi_dq_o = 32'h80;
//     onfi_dq_en = 1;
//     @(negedge onfi_clk);//addr1
//     onfi_cle = 0;
//     onfi_ale = 1;
//     onfi_dq_o = addr;
//     @(negedge onfi_clk);//addr2
//     onfi_cle = 0;
//     onfi_ale = 1;
//     onfi_dq_o = length;
//     @(negedge onfi_clk);//data
//     onfi_ale = 0;
//     onfi_dq_en = 0;
//     data_tmp1 = data;
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
//             @(posedge onfi_clk);
//             onfi_dqs_en = 1;
//             onfi_dq_en = 1;
//             {data_tmp2, onfi_dq_o} = {32'h00000000, data_tmp1};
//             @(negedge onfi_clk);
//             {data_tmp1, onfi_dq_o} = {32'h00000000, data_tmp2};
//         end
//         @(posedge onfi_clk);
//         onfi_dqs_en = 0;
//         onfi_dq_en = 0;
//     end
//     join
//     @(negedge onfi_clk);
//     onfi_cen = 1;
//     onfi_cle = 0;
//     onfi_ale = 0;
//     onfi_wen = 1;
// end
// endtask