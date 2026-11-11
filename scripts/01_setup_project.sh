#!/usr/bin/env bash
# ==============================================================================
# Script: 01_setup_project.sh
# Phụ trách: Thành viên 2
# Chức năng: Khởi tạo cây thư mục chuẩn, kiểm tra tệp đầu vào, phân quyền
# ==============================================================================

set -e
CONFIG_FILE="config/eda.conf"

GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}=== [TV2] KHOI TAO CAU TRUC DU AN EDA ===${RESET}"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo -e "${GREEN}[✓] Da nap file cau hinh: ${CONFIG_FILE}${RESET}"
else
    echo -e "${YELLOW}[!] Khong tim thay file cau hinh, su dung ten mac dinh.${RESET}"
    DIR_SRC="src"; DIR_TB="tb"; DIR_SCRIPTS="scripts"
    DIR_LOGS="logs"; DIR_REPORTS="reports"; DIR_RESULTS="results"
fi

# Tạo cây thư mục làm việc chuẩn
echo -e "${CYAN}[*] Dang tao cac thu muc lam viec...${RESET}"
mkdir -p "${DIR_SRC}" "${DIR_TB}" "${DIR_SCRIPTS}" "${DIR_LOGS}" "${DIR_REPORTS}" "${DIR_RESULTS}"

# Phân quyền chuẩn Linux: 755 cho thư mục và script, 644 cho file mã nguồn
echo -e "${CYAN}[*] Dang thiet lap quyen truy cap file...${RESET}"
chmod 755 scripts/*.sh 2>/dev/null || true
chmod 644 "${DIR_SRC}"/*.v 2>/dev/null || true
chmod 644 "${DIR_TB}"/*.v 2>/dev/null || true

echo -e "${GREEN}[✓] Khoi tao moi truong va phan quyen thanh cong!${RESET}"
echo "--------------------------------------------------------"
if command -v tree >/dev/null 2>&1; then
    tree -L 2 .
else
    ls -la
fi
echo "--------------------------------------------------------"
