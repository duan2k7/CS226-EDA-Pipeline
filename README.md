# HƯỚNG DẪN SỬ DỤNG HỆ THỐNG EDA AUTOMATION PIPELINE
## Đồ án CS226 - Đề tài 18: Tự động hóa quy trình mô phỏng và tổng hợp mạch số trên Linux bằng Shell Script
**Giảng viên hướng dẫn:** Th.S Trần Hữu Minh Đăng  
**Đơn vị:** Khoa Kỹ thuật Mạng Máy tính & Truyền thông – Đại học Duy Tân  

---

## 1. Giới thiệu tổng quan
Dự án cung cấp bộ công cụ dòng lệnh bằng Bash Shell Script nhằm tự động hóa 100% các công đoạn trong quy trình thiết kế vi mạch số:
* Khởi tạo và chuẩn hóa cấu trúc dự án.
* Biên dịch và mô phỏng mạch Verilog bằng **Icarus Verilog (`iverilog`, `vvp`)**.
* Xuất và trực quan hóa dạng sóng bằng **GTKWave**.
* Tổng hợp mạch logic (Logic Synthesis) ra cổng Netlist bằng **Yosys**.
* Phân tích log tự động (Log Parser), phát hiện Warning/Error và xuất báo cáo Text & HTML.

---

## 2. Yêu cầu môi trường & Cài đặt 1-Click
Hệ thống chạy trên mọi bản phân phối Linux (Ubuntu, Debian, Fedora, Arch...).

Để cài đặt đầy đủ các công cụ cần thiết, chỉ cần chạy script:
```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```
Hoặc cài thủ công qua APT:
```bash
sudo apt update && sudo apt install -y iverilog yosys gtkwave tree
```

---

## 3. Cấu trúc thư mục dự án
```text
EDA_Automation_Project/
├── config/
│   └── eda.conf                # File cấu hình thông số dự án
├── src/
│   └── counter_8bit.v          # Mã nguồn Verilog của mạch số (UUT)
├── tb/
│   └── counter_8bit_tb.v       # Testbench kiểm thử tự động
├── scripts/
│   ├── 01_setup_project.sh     # Script khởi tạo & phân quyền (TV2)
│   ├── 02_run_sim.sh           # Script mô phỏng Verilog (TV3)
│   ├── 03_run_synth.sh         # Script tổng hợp Yosys (TV4)
│   └── 04_parse_log.sh         # Script phân tích log & báo cáo (TV5)
├── logs/                       # Nơi lưu toàn bộ log thực thi theo timestamp
├── reports/                    # Báo cáo thống kê tài nguyên & báo cáo Text/HTML
├── results/                    # File sóng .vcd, binary mô phỏng, Netlist .v
├── eda_pipeline.sh             # Master script điều phối toàn bộ pipeline (TV6)
├── install_dependencies.sh     # Script cài đặt môi trường
└── README.md                   # Tài liệu hướng dẫn sử dụng
```

---

## 4. Hướng dẫn sử dụng

### Cách 1: Sử dụng Menu tương tác trực quan
Chạy lệnh trực tiếp không kèm tham số:
```bash
chmod +x eda_pipeline.sh scripts/*.sh
./eda_pipeline.sh
```
Hệ thống sẽ hiển thị Menu số từ 1 đến 8 để bạn lựa chọn thao tác.

### Cách 2: Sử dụng các cờ dòng lệnh (CLI Flags)
* **Khởi tạo thư mục và phân quyền:**
  ```bash
  ./eda_pipeline.sh --setup
  ```
* **Chạy mô phỏng kiểm thử:**
  ```bash
  ./eda_pipeline.sh --sim
  ```
* **Chạy tổng hợp mạch logic:**
  ```bash
  ./eda_pipeline.sh --synth
  ```
* **Phân tích log và xuất báo cáo:**
  ```bash
  ./eda_pipeline.sh --report
  ```
* **Chạy trọn gói toàn bộ quy trình từ A đến Z (1-Click):**
  ```bash
  ./eda_pipeline.sh --all
  ```
* **Xem dạng sóng trên GTKWave:**
  ```bash
  gtkwave results/waves.vcd
  ```
* **Dọn dẹp tệp tin tạm để chạy lại:**
  ```bash
  ./eda_pipeline.sh --clean
  ```

---

## 5. Tùy biến mạch số mới
Khi muốn áp dụng cho một mạch khác (ví dụ mạch ALU hay FSM):
1. Đặt file Verilog mới vào thư mục `src/`.
2. Đặt file Testbench mới vào thư mục `tb/`.
3. Mở file [config/eda.conf](file:///home/duanle/Documents/DO%20AN/EDA_Automation_Project/config/eda.conf) và thay đổi `TOP_MODULE`, `SRC_FILES`, `TB_FILE`.
4. Chạy `./eda_pipeline.sh --all` để tận hưởng quy trình tự động!
