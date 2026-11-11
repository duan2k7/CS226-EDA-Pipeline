#!/usr/bin/env bash
# ==============================================================================
# Script: eda_pipeline.sh (Master Orchestrator)
# Phụ trách: Thành viên 6
# Chức năng: Điều phối toàn bộ quy trình EDA, hỗ trợ CLI flags và Menu tương tác
# Môn học: Hệ điều hành UNIX/Linux (CS226) - Đề tài 18
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "=================================================================="
    echo "          HỆ THỐNG TỰ ĐỘNG HÓA EDA PIPELINE TRÊN LINUX            "
    echo "       Môn học: CS226 - Giảng viên: Th.S Trần Hữu Minh Đăng       "
    echo "=================================================================="
    echo -e "${RESET}"
}

run_setup() {
    bash scripts/01_setup_project.sh
}

run_simulation() {
    bash scripts/02_run_sim.sh
}

run_synthesis() {
    bash scripts/03_run_synth.sh
}

run_report() {
    bash scripts/04_parse_log.sh
}

run_all() {
    print_banner
    echo -e "${YELLOW}[!] Bat dau chay toan bo quy trinh EDA Pipeline tu A den Z...${RESET}"
    START_ALL=$(date +%s%N)

    run_setup
    echo ""
    run_simulation
    echo ""
    run_synthesis
    echo ""
    run_report

    END_ALL=$(date +%s%N)
    TOTAL_MS=$(( (END_ALL - START_ALL) / 1000000 ))
    echo -e "${GREEN}${BOLD}=================================================================="
    echo -e "   [✓] TOAN BO PIPELINE DA CHAY XONG TRONG: ${TOTAL_MS} ms!       "
    echo -e "==================================================================${RESET}"
}

clean_artifacts() {
    echo -e "${YELLOW}[*] Dang xoa bo nho dem, log va cac file ket qua cu...${RESET}"
    rm -rf results/* logs/* reports/*
    echo -e "${GREEN}[✓] Da don dep he thong sach se!${RESET}"
}

show_menu() {
    while true; do
        print_banner
        echo "Vui lòng chọn chức năng:"
        echo "  1) Khởi tạo cấu trúc dự án & phân quyền (TV2)"
        echo "  2) Chạy mô phỏng mạch số bằng Icarus Verilog (TV3)"
        echo "  3) Chạy tổng hợp mạch logic bằng Yosys (TV4)"
        echo "  4) Phân tích log & xuất báo cáo tự động (TV5)"
        echo "  5) Chạy toàn bộ quy trình (Master Pipeline 1-Click)"
        echo "  6) Mở giao diện sóng đồ thị GTKWave (nếu có X11/Wayland)"
        echo "  7) Dọn dẹp tệp tin tạm (Clean)"
        echo "  8) Thoát"
        echo "------------------------------------------------------------------"
        read -rp "Nhập lựa chọn của bạn [1-8]: " choice
        case $choice in
            1) run_setup ;;
            2) run_simulation ;;
            3) run_synthesis ;;
            4) run_report ;;
            5) run_all ;;
            6)
                if [ -f "results/waves.vcd" ]; then
                    gtkwave results/waves.vcd &
                else
                    echo -e "${RED}[!] Chua co file results/waves.vcd! Hay chay mo phong truoc.${RESET}"
                fi
                ;;
            7) clean_artifacts ;;
            8) echo "Tạm biệt!"; exit 0 ;;
            *) echo -e "${RED}Lựa chọn không hợp lệ!${RESET}" ;;
        esac
        echo ""
        read -rp "Nhấn Enter để tiếp tục..."
    done
}

# Xử lý cờ dòng lệnh (CLI flags)
if [ $# -eq 0 ]; then
    show_menu
else
    case "$1" in
        --setup)
            run_setup
            ;;
        --sim)
            run_simulation
            ;;
        --synth)
            run_synthesis
            ;;
        --report)
            run_report
            ;;
        --all)
            run_all
            ;;
        --clean)
            clean_artifacts
            ;;
        -h|--help)
            print_banner
            echo "Cách sử dụng:"
            echo "  $0                  : Mở menu tương tác trực quan"
            echo "  $0 --setup          : Khởi tạo cấu trúc dự án & phân quyền"
            echo "  $0 --sim            : Chạy mô phỏng Verilog"
            echo "  $0 --synth          : Chạy tổng hợp logic Yosys"
            echo "  $0 --report         : Phân tích log & tạo báo cáo Text/HTML"
            echo "  $0 --all            : Chạy toàn bộ quy trình từ đầu đến cuối"
            echo "  $0 --clean          : Xóa toàn bộ file kết quả và log cũ"
            ;;
        *)
            echo -e "${RED}Tham số không hợp lệ: $1${RESET}"
            echo "Sử dụng $0 --help để xem hướng dẫn."
            exit 1
            ;;
    esac
fi
