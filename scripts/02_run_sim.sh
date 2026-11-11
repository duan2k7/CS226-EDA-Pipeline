#!/usr/bin/env bash
# ==============================================================================
# Script: 02_run_sim.sh
# Phụ trách: Thành viên 3
# Chức năng: Tự động biên dịch & mô phỏng mạch Verilog bằng Icarus Verilog
# ==============================================================================

set -e
CONFIG_FILE="config/eda.conf"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}=== [TV3] CHAY MO PHONG MACH SO BANG ICARUS VERILOG ===${RESET}"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}[Loi] Khong tim thay file cau hinh ${CONFIG_FILE}!${RESET}"
    exit 1
fi

# 1. Kiểm tra công cụ cần thiết
if ! command -v iverilog >/dev/null 2>&1; then
    echo -e "${RED}[Loi] Chua cai dat iverilog! Hay chay: sudo apt install -y iverilog${RESET}"
    exit 1
fi

# 2. Kiểm tra các file đầu vào
if [ ! -f "${SRC_FILES}" ]; then
    echo -e "${RED}[Loi] File ma nguon ${SRC_FILES} khong ton tai!${RESET}"
    exit 1
fi

if [ ! -f "${TB_FILE}" ]; then
    echo -e "${RED}[Loi] File testbench ${TB_FILE} khong ton tai!${RESET}"
    exit 1
fi

# 3. Tạo tên file log theo timestamp
mkdir -p "${DIR_LOGS}" "${DIR_RESULTS}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${DIR_LOGS}/sim_${TIMESTAMP}.log"

echo -e "${CYAN}[*] Dang bien dich Verilog: ${SRC_FILES} & ${TB_FILE}...${RESET}"
START_TIME=$(date +%s%N)

# Biên dịch Verilog
if iverilog -o "${SIM_OUT}" "${SRC_FILES}" "${TB_FILE}" 2>&1 | tee "${LOG_FILE}"; then
    echo -e "${GREEN}[✓] Bien dich thanh cong! File binary: ${SIM_OUT}${RESET}"
else
    echo -e "${RED}[✗] Bien dich that bai! Chi tiet xem tai: ${LOG_FILE}${RESET}"
    exit 1
fi

# Chạy mô phỏng bằng máy ảo VVP
echo -e "${CYAN}[*] Dang thuc thi mo phong bang vvp...${RESET}"
vvp "${SIM_OUT}" 2>&1 | tee -a "${LOG_FILE}"

END_TIME=$(date +%s%N)
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

echo "--------------------------------------------------------"
if grep -q "ALL TESTS COMPLETED SUCCESSFULLY" "${LOG_FILE}"; then
    echo -e "${GREEN}[✓] KET QUA MO PHONG: PASS (Hoan thanh trong ${ELAPSED_MS} ms)${RESET}"
    echo -e "${GREEN}[✓] File song VCD da xuat tai: ${VCD_OUT}${RESET}"
    echo -e "${CYAN}[Mẹo] De xem dang song do thi: gtkwave ${VCD_OUT}${RESET}"
else
    echo -e "${RED}[✗] KET QUA MO PHONG: FAIL (Phat hien loi trong qua trinh mo phong)${RESET}"
fi
echo -e "${CYAN}[*] Toan bo log da duoc luu tai: ${LOG_FILE}${RESET}"
echo "--------------------------------------------------------"
