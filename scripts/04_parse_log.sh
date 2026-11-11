#!/usr/bin/env bash
# ==============================================================================
# Script: 04_parse_log.sh
# Phụ trách: Thành viên 5
# Chức năng: Quét và phân tích log, trích xuất cảnh báo, lỗi và tạo báo cáo
# ==============================================================================

set -e
CONFIG_FILE="config/eda.conf"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}=== [TV5] PHAN TICH LOG & TAO BAO CAO TU DONG ===${RESET}"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    DIR_LOGS="logs"
    DIR_REPORTS="reports"
fi

mkdir -p "${DIR_REPORTS}"

# Tìm file log mô phỏng và tổng hợp mới nhất
LATEST_SIM_LOG=$(ls -t ${DIR_LOGS}/sim_*.log 2>/dev/null | head -n 1 || true)
LATEST_SYNTH_LOG=$(ls -t ${DIR_LOGS}/synth_*.log 2>/dev/null | head -n 1 || true)

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TXT_REPORT="${DIR_REPORTS}/summary_report_${TIMESTAMP}.txt"
HTML_REPORT="${DIR_REPORTS}/summary_report_${TIMESTAMP}.html"

# 1. Tạo báo cáo dạng văn bản Text
{
    echo "=========================================================="
    echo "          BAO CAO TONG HOP EDA AUTOMATION PIPELINE        "
    echo "          Du an: ${PROJECT_NAME}                          "
    echo "          Thoi gian tao: $(date)                          "
    echo "=========================================================="
    echo ""

    # Phân tích Log mô phỏng
    echo "[1] KET QUA MO PHONG (SIMULATION):"
    if [ -n "$LATEST_SIM_LOG" ] && [ -f "$LATEST_SIM_LOG" ]; then
        echo "  - File log: $LATEST_SIM_LOG"
        # Lọc cảnh báo và lỗi thông minh, loại trừ "0 errors"
        SIM_WARNS=$(grep -i -E "(warning|warn)" "$LATEST_SIM_LOG" | grep -v -i "0 warnings" | wc -l || true)
        SIM_ERRS=$(grep -i -E "(error|fail)" "$LATEST_SIM_LOG" | grep -v -i "0 errors" | wc -l || true)
        echo "  - So luong Warnings: $SIM_WARNS"
        echo "  - So luong Errors  : $SIM_ERRS"
        
        if grep -q "ALL TESTS COMPLETED SUCCESSFULLY" "$LATEST_SIM_LOG"; then
            echo "  - Trang thai: [PASS] - Chay thanh cong 100%"
        else
            echo "  - Trang thai: [FAIL] - Co loi xay ra trong mo phong!"
        fi
        
        if [ "$SIM_ERRS" -gt 0 ]; then
            echo "  - Danh sach dong loi phat hien:"
            grep -i -n "error" "$LATEST_SIM_LOG" | head -n 10 | sed 's/^/      /'
        fi
    else
        echo "  - Khong tim thay file log mo phong!"
    fi
    echo ""

    # Phân tích Log tổng hợp
    echo "[2] KET QUA TONG HOP (SYNTHESIS):"
    if [ -n "$LATEST_SYNTH_LOG" ] && [ -f "$LATEST_SYNTH_LOG" ]; then
        echo "  - File log: $LATEST_SYNTH_LOG"
        SYN_WARNS=$(grep -i -E "(warning|warn)" "$LATEST_SYNTH_LOG" | grep -v -i "0 warnings" | wc -l || true)
        SYN_ERRS=$(grep -i -E "(error|fail)" "$LATEST_SYNTH_LOG" | grep -v -i "0 errors" | wc -l || true)
        echo "  - So luong Warnings: $SYN_WARNS"
        echo "  - So luong Errors  : $SYN_ERRS"

        echo "  - Thong ke tai nguyen vi mach (Cell Count):"
        CELL_STATS=$(awk '/Printing statistics/,/Executing Verilog backend/' "$LATEST_SYNTH_LOG" | grep -v -E "Printing statistics|Executing Verilog backend" || true)
        if [ -z "$(echo "$CELL_STATS" | tr -d '[:space:]')" ]; then
            CELL_STATS=$(awk '/=== design hierarchy ===/,/=== end of design hierarchy ===/' "$LATEST_SYNTH_LOG" || true)
        fi
        echo "$CELL_STATS" | sed 's/^/      /'
    else
        echo "  - Khong tim thay file log tong hop!"
    fi
    echo ""
    echo "=========================================================="
} > "${TXT_REPORT}"

# 2. Tạo báo cáo giao diện HTML trực quan
cat <<EOF > "${HTML_REPORT}"
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo Cáo Tự Động EDA Pipeline</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 30px; background: #f4f6f9; color: #333; }
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h1 { color: #0066cc; margin-top: 0; }
        .badge-pass { background: #28a745; color: white; padding: 5px 12px; border-radius: 4px; font-weight: bold; }
        .badge-fail { background: #dc3545; color: white; padding: 5px 12px; border-radius: 4px; font-weight: bold; }
        pre { background: #272822; color: #f8f8f2; padding: 15px; border-radius: 6px; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background: #0066cc; color: white; }
    </style>
</head>
<body>
    <div class="card">
        <h1>📊 Báo Cáo Kết Quả EDA Pipeline</h1>
        <p><strong>Dự án:</strong> ${PROJECT_NAME} | <strong>Thời gian:</strong> $(date)</p>
    </div>
    <div class="card">
        <h2>1. Kết quả Mô phỏng (Simulation)</h2>
        <p>Log: <code>${LATEST_SIM_LOG}</code></p>
        <span class="badge-pass">TEST COMPLETED</span>
    </div>
    <div class="card">
        <h2>2. Kết quả Tổng hợp Mạch (Synthesis)</h2>
        <p>Log: <code>${LATEST_SYNTH_LOG}</code></p>
        <pre>${CELL_STATS:-Chưa có dữ liệu}</pre>
    </div>
</body>
</html>
EOF

# In ra màn hình terminal
cat "${TXT_REPORT}"
echo "--------------------------------------------------------"
echo -e "${GREEN}[✓] Da xuat bao cao dang Text: ${TXT_REPORT}${RESET}"
echo -e "${GREEN}[✓] Da xuat bao cao dang HTML: ${HTML_REPORT}${RESET}"
echo "--------------------------------------------------------"
