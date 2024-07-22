// task wait_for_ready;
// begin
//     get_status(get_feature_data);
//     while(get_feature_data != 32'h00000000) begin
//         $display("wait for ready, now is %h", get_feature_data[15:0]);
//         #1000;
//         get_status(get_feature_data);
//     end
// end
// endtask