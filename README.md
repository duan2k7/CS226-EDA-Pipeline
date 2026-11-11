# ⚡ EDA Automation Pipeline trên Linux
> **Đồ án môn học CS226 - Hệ điều hành UNIX/Linux | Đề tài 18**  
> **Trường Trí tuệ Nhân tạo & Thông tin (SDA) – Đại học Duy Tân**  
> **Giảng viên hướng dẫn:** Th.S Trần Hữu Minh Đăng | **Nhóm thực hiện:** Nhóm 04

---

## 💡 30 Giây Hiểu Ngay Dự Án (TL;DR)

* **Vấn đề thực tế:** Khi thiết kế vi mạch (chip) trên Linux bằng ngôn ngữ Verilog, mỗi lần sửa code, kỹ sư phải gõ hàng chục câu lệnh thủ công phức tạp: tạo thư mục, biên dịch mô phỏng (`iverilog`), chạy thử nghiệm (`vvp`), vẽ đồ thị sóng (`gtkwave`), tổng hợp ra cổng logic (`yosys`), rồi căng mắt đọc hàng nghìn dòng log để tìm lỗi.
* **Giải pháp của dự án:** Chúng mình đã dùng **Bash Shell Script** đóng gói toàn bộ quy trình trên thành một dây chuyền tự động hóa khép kín:
  ```bash
  ./eda_pipeline.sh --all
  ```
* **Kết quả:** Thay vì mất gần 8 phút làm thủ công, hệ thống tự động chạy từ A đến Z chỉ trong **0.2 giây (173 ms)**, triệt tiêu 100% lỗi gõ nhầm lệnh và tự động xuất ra bản báo cáo tóm tắt đẹp mắt (cả dạng Terminal Text và Web HTML)!

---

## 🚀 Bắt Đầu Nhanh (Chỉ 2 Bước)

### 1. Cài đặt các công cụ cần thiết (Chạy 1 lần duy nhất)
```bash
sudo apt update && sudo apt install -y iverilog yosys gtkwave
```
*(Hoặc chạy script cài đặt tự động có sẵn: `./install_dependencies.sh`)*

### 2. Chạy toàn bộ quy trình tự động!
```bash
./eda_pipeline.sh --all
```

---

## 🔄 Dây Chuyền Hoạt Động (EDA Pipeline Flow)

```text
[Mã nguồn Verilog] ──> [01_setup_project.sh] ──> Tự động tạo thư mục & phân quyền
         │
         ▼
[02_run_sim.sh]    ──> Icarus Verilog + vvp  ──> Xuất file sóng (results/waves.vcd)
         │
         ▼
[03_run_synth.sh]  ──> Yosys Synthesis       ──> Xuất Netlist (results/counter_synth.v)
         │                                       và Thống kê cổng logic (Cell Count)
         ▼
[04_parse_log.sh]  ──> Quét log (grep/awk)   ──> Xuất Báo cáo Tóm tắt:
                                                 ├── reports/summary_report_*.txt (Terminal)
                                                 └── reports/summary_report_*.html (Trình duyệt)
```

---

## 🎮 Các Chế Độ Sử Dụng

### 1. Chế độ Menu tương tác trực quan
Nếu không muốn nhớ câu lệnh, chỉ cần gõ:
```bash
./eda_pipeline.sh
```
Hệ thống sẽ bật Menu số để bạn bấm chọn từng bước:
```text
==================================================================
          HỆ THỐNG TỰ ĐỘNG HÓA EDA PIPELINE TRÊN LINUX            
==================================================================
  1. Khoi tao cau truc thu muc du an (Setup)
  2. Chay mo phong mach so Verilog (Simulation)
  3. Chay tong hop mach logic bang Yosys (Synthesis)
  4. Phan tich log va xuat bao cao (Report)
  5. Mo dang song do thi bang GTKWave (Waveform Viewer)
  6. Chay toan bo quy trinh tu A den Z (All-in-One)
  7. Don dep tep tin tam va ket qua cu (Clean)
  0. Thoat chuong trinh
==================================================================
Nhap lua chon cua ban [0-7]: 
```

### 2. Chế độ dòng lệnh nhanh (CLI Flags)
| Câu lệnh | Chức năng |
| :--- | :--- |
| `./eda_pipeline.sh --all` | Chạy toàn bộ dây chuyền từ A đến Z (1-Click) |
| `./eda_pipeline.sh --setup` | Khởi tạo cấu trúc 6 thư mục chuẩn & phân quyền `chmod 755` |
| `./eda_pipeline.sh --sim` | Chỉ chạy mô phỏng Verilog & xuất file sóng `.vcd` |
| `./eda_pipeline.sh --synth` | Chỉ chạy tổng hợp logic vi mạch bằng Yosys |
| `./eda_pipeline.sh --report` | Quét log bắt lỗi và xuất báo cáo Text & HTML |
| `gtkwave results/waves.vcd` | Bật cửa sổ xem biểu đồ sóng tín hiệu số |
| `xdg-open reports/*.html` | Mở báo cáo kết quả bằng trình duyệt Web |
| `./eda_pipeline.sh --clean` | Dọn dẹp sạch sẽ các file rác và log cũ |

---

## 📊 Kết Quả Minh Chứng Thực Nghiệm

Khi chạy lệnh `./eda_pipeline.sh --all`, hệ thống trả về kết quả định lượng thực tế:

* **Mô phỏng logic (Simulation):** Đạt **`[PASS] 100%`** qua cả 4 bài test (Reset, Đếm lên, Đếm xuống, Khóa mạch).
* **Tổng hợp mạch (Synthesis):** Chuyển đổi mã Verilog thành **63 tế bào logic** thực tế (18 cổng AND, 8 D-FlipFlop, 7 MUX, 8 NOT, 8 OR, 14 XOR).
* **So sánh hiệu năng:**
  * **Làm thủ công:** Trung bình **452 giây** (~7.5 phút), xuất hiện 2.7 lỗi gõ nhầm lệnh/lần.
  * **Dùng Shell Script:** Chỉ **0.17 giây (173 ms)**, **0 lỗi** sai sót.
  * 👉 **Tốc độ nhanh hơn 214.2 lần (>21,400%)!**

---

## 👥 Phân Công Nhiệm Vụ Thành Viên (Nhóm 04)

| Thành viên | Module phụ trách | File Script đảm nhiệm | Nội dung thực hiện |
| :--- | :---: | :--- | :--- |
| **Trần Huy Lâm** | **1.0** | Khảo sát Benchmark | Nghiên cứu lý thuyết tự động hóa; thực hiện đo đạc đối chứng thủ công vs script. |
| **Nguyễn Ngọc Huy** | **2.0** | `01_setup_project.sh`<br>`src/counter_8bit.v` | Chuẩn hóa cấu trúc 6 thư mục; chuẩn bị thiết kế mẫu bộ đếm Verilog 8-bit. |
| **Trần Trung Thông** | **3.0** | `02_run_sim.sh`<br>`tb/counter_8bit_tb.v` | Tự động hóa bước mô phỏng với Icarus Verilog (`iverilog`, `vvp`) & xuất file sóng `.vcd`. |
| **Nguyễn Phúc Hưng** | **4.0** | `03_run_synth.sh` | Tự động hóa bước tổng hợp vi mạch bằng Yosys; xuất Netlist cổng logic và thống kê Cell Count. |
| **Lê Văn Duẩn** *(Trưởng nhóm)* | **5.0 & 6.0** | `04_parse_log.sh`<br>`eda_pipeline.sh` | Bóc tách log bắt lỗi bằng `grep/awk/sed`, xuất báo cáo Text/HTML; xây dựng Master Pipeline điều phối. |

---

## 📁 Cấu Trúc Thư Mục Dự Án

```text
2026S_CS226_Nhom04_DT18/
├── config/
│   └── eda.conf                # File cấu hình tham số dự án (tên module, file nguồn)
├── src/
│   └── counter_8bit.v          # Mã nguồn Verilog của mạch số (UUT)
├── tb/
│   └── counter_8bit_tb.v       # Testbench tự động kiểm thử kích thích
├── scripts/
│   ├── 01_setup_project.sh     # [TV2] Khởi tạo thư mục & phân quyền chmod
│   ├── 02_run_sim.sh           # [TV3] Chạy mô phỏng Icarus Verilog
│   ├── 03_run_synth.sh         # [TV4] Chạy tổng hợp vi mạch Yosys
│   └── 04_parse_log.sh         # [TV5] Phân tích log & xuất báo cáo Text/HTML
├── logs/                       # Lưu trữ toàn bộ log theo mốc thời gian timestamp
├── reports/                    # Lưu báo cáo thống kê tài nguyên & báo cáo Text/HTML
├── results/                    # File sóng .vcd, binary mô phỏng, Netlist sau tổng hợp
├── eda_pipeline.sh             # [TV6] Script điều phối trung tâm Master Pipeline
├── install_dependencies.sh     # Script cài đặt công cụ tự động
├── GIAI_THICH_MA_NGUON.txt     # Hướng dẫn chi tiết bằng tiếng Việt
└── README.md                   # Tài liệu hướng dẫn sử dụng chính thức
```

---

## 🔧 Áp Dụng Cho Mạch Mới (Tính Tái Sử Dụng)

Hệ thống được thiết kế theo cấu trúc mở, có thể dùng lại cho bất kỳ thiết kế mạch số nào:
1. Thả file code Verilog mới vào thư mục `src/`.
2. Thả file Testbench mới vào thư mục `tb/`.
3. Mở file `config/eda.conf` sửa biến `TOP_MODULE` và tên file tương ứng.
4. Chạy `./eda_pipeline.sh --all` là toàn bộ quy trình sẽ tự động xử lý mạch mới ngay lập tức!
