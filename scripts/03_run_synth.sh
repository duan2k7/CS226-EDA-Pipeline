#!/usr/bin/env bash
# ==============================================================================
# Script: 03_run_synth.sh
# Phụ trách: Thành viên 4
# Chức năng: Tự động tổng hợp mạch logic bằng Yosys & thống kê tài nguyên
# ==============================================================================

set -e
CONFIG_FILE="config/eda.conf"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}=== [TV4] TONG HOP MACH LOGIC BANG YOSYS ===${RESET}"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}[Loi] Khong tim thay file cau hinh ${CONFIG_FILE}!${RESET}"
    exit 1
fi

# 1. Kiểm tra công cụ Yosys
if ! command -v yosys >/dev/null 2>&1; then
    echo -e "${RED}[Loi] Chua cai dat Yosys! Hay chay: sudo apt install -y yosys${RESET}"
    exit 1
fi

# 2. Kiểm tra file nguồn
if [ ! -f "${SRC_FILES}" ]; then
    echo -e "${RED}[Loi] File ma nguon ${SRC_FILES} khong ton tai!${RESET}"
    exit 1
fi

mkdir -p "${DIR_LOGS}" "${DIR_REPORTS}" "${DIR_RESULTS}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${DIR_LOGS}/synth_${TIMESTAMP}.log"
REPORT_FILE="${DIR_REPORTS}/synth_stat_${TIMESTAMP}.txt"

# 3. Tạo file script lệnh Yosys tự động
echo -e "${CYAN}[*] Dang tao tap lenh tong hop Yosys (${YS_SCRIPT})...${RESET}"
cat <<EOF > "${YS_SCRIPT}"
# Yosys synthesis script for ${TOP_MODULE}
read_verilog ${SRC_FILES}
hierarchy -check -top ${TOP_MODULE}
proc
opt
fsm
opt
memory
opt
techmap
opt
stat
write_verilog ${NETLIST_OUT}
EOF

# 4. Thực thi tổng hợp
echo -e "${CYAN}[*] Dang chay Yosys synthesis...${RESET}"
START_TIME=$(date +%s%N)

if yosys -s "${YS_SCRIPT}" 2>&1 | tee "${LOG_FILE}"; then
    echo -e "${GREEN}[✓] Tong hop thanh cong!${RESET}"
else
    echo -e "${RED}[✗] Tong hop that bai! Kiem tra log tai ${LOG_FILE}${RESET}"
    exit 1
fi

END_TIME=$(date +%s%N)
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

# 5. Trích xuất bảng thống kê tài nguyên mạch
echo "========================================================" > "${REPORT_FILE}"
echo "    THONG KE TAI NGUYEN MACH LOGIC: ${TOP_MODULE}       " >> "${REPORT_FILE}"
echo "    Thoi gian: $(date)                                  " >> "${REPORT_FILE}"
echo "========================================================" >> "${REPORT_FILE}"
awk '/=== design hierarchy ===/,/=== end of design hierarchy ===/' "${LOG_FILE}" >> "${REPORT_FILE}" || true
awk '/Printing statistics/,/=== END OF FINANCIAL STATISTICS/' "${LOG_FILE}" >> "${REPORT_FILE}" 2>/dev/null || true

echo "--------------------------------------------------------"
echo -e "${GREEN}[✓] Thoi gian tong hop: ${ELAPSED_MS} ms${RESET}"
echo -e "${GREEN}[✓] Netlist cong logic da xuat tai: ${NETLIST_OUT}${RESET}"
echo -e "${GREEN}[✓] Bao cao thong ke tai nguyen da luu tai: ${REPORT_FILE}${RESET}"
echo -e "${CYAN}[*] Toan bo log chi tiet luu tai: ${LOG_FILE}${RESET}"
echo "--------------------------------------------------------"
