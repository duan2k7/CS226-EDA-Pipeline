// ==============================================================================
// Testbench: counter_8bit_tb
// Mô tả: Kịch bản kiểm thử tự động cho module counter_8bit
//        Sinh xung clock, kiểm tra trạng thái reset, đếm lên, đếm xuống,
//        tự động kiểm tra điều kiện và xuất thông báo PASS/FAIL.
// Môn học: Hệ điều hành UNIX/Linux (CS226) - Đề tài 18
// ==============================================================================

`timescale 1ns/1ps

module counter_8bit_tb;

    // Khai báo tín hiệu kích thích (Inputs to UUT)
    reg        clk;
    reg        rst_n;
    reg        enable;
    reg        up_down;

    // Khai báo tín hiệu quan sát (Outputs from UUT)
    wire [7:0] count;

    // Biến đếm lỗi kiểm thử tự động
    integer error_count = 0;

    // Kết nối Unit Under Test (UUT)
    counter_8bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .up_down(up_down),
        .count(count)
    );

    // Sinh xung Clock tần số 50MHz (Chu kỳ T = 20ns)
    always #10 clk = ~clk;

    initial begin
        // Thiết lập ghi nhận dạng sóng cho GTKWave
        $dumpfile("results/waves.vcd");
        $dumpvars(0, counter_8bit_tb);

        // Khởi tạo các tín hiệu
        clk     = 0;
        rst_n   = 0;
        enable  = 0;
        up_down = 1;

        $display("--------------------------------------------------");
        $display("[TB] BAT DAU KIEM THU MODULE COUNTER_8BIT");
        $display("--------------------------------------------------");

        // 1. Kiểm tra Reset (Active-Low)
        #25;
        if (count !== 8'h00) begin
            $display("[FAIL] Loi Reset: count = %h (mong doi 00)", count);
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Reset thanh cong, count = 00");
        end

        // Thả Reset
        rst_n = 1;
        #15;

        // 2. Kiểm tra đếm lên (Count Up)
        enable = 1;
        up_down = 1;
        #100; // Cho đếm 5 chu kỳ clock
        if (count !== 8'h05) begin
            $display("[FAIL] Loi Count Up: count = %d (mong doi 5)", count);
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Count Up thanh cong, count = %d", count);
        end

        // 3. Kiểm tra đếm xuống (Count Down)
        up_down = 0;
        #60; // Đếm xuống 3 chu kỳ: 5 - 3 = 2
        if (count !== 8'h02) begin
            $display("[FAIL] Loi Count Down: count = %d (mong doi 2)", count);
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Count Down thanh cong, count = %d", count);
        end

        // 4. Kiểm tra vô hiệu hóa đếm (Enable = 0)
        enable = 0;
        #40;
        if (count !== 8'h02) begin
            $display("[FAIL] Loi Disable: count bi thay doi = %d", count);
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Disable thanh cong, count giu nguyen = %d", count);
        end

        // Kết luận kiểm thử
        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("[SIMULATION] ALL TESTS COMPLETED SUCCESSFULLY");
            $display("[RESULT] TEST PASS - MODULE HOAT DONG DUNG THIET KE");
        end else begin
            $display("[SIMULATION] FAILED WITH %d ERRORS", error_count);
            $display("[RESULT] TEST FAIL - CO LOI TRONG LOGIC THIET KE");
        end
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
