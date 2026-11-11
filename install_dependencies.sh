#!/usr/bin/env bash
# ==============================================================================
# CS226 - Cài đặt môi trường EDA tự động cho Ubuntu/Debian
# Đề tài 18: Tự động hóa quy trình mô phỏng và tổng hợp mạch số trên Linux
# ==============================================================================

echo "=========================================================="
echo "   CS226: CÀI ĐẶT CÔNG CỤ EDA MÃ NGUỒN MỞ TRÊN LINUX     "
echo "   Các công cụ: Icarus Verilog, Yosys, GTKWave            "
echo "=========================================================="

echo "[1/3] Cập nhật danh sách gói phần mềm..."
sudo apt update

echo "[2/3] Đang cài đặt iverilog, yosys, gtkwave..."
sudo apt install -y iverilog yosys gtkwave

echo "[3/3] Kiểm tra phiên bản sau khi cài đặt:"
echo -n "  - Icarus Verilog: "
iverilog -V 2>/dev/null | head -n 1 || echo "Chưa cài đặt được"
echo -n "  - Yosys: "
yosys -V 2>/dev/null || echo "Chưa cài đặt được"
echo -n "  - GTKWave: "
gtkwave --version 2>/dev/null | head -n 1 || echo "Chưa cài đặt được"

echo "=========================================================="
echo "   Hoàn tất! Môi trường đã sẵn sàng để chạy pipeline!     "
echo "=========================================================="
