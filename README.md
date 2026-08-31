# Lõi IP CORDIC 32-bit trên FPGA

Dự án thiết kế và hiện thực hóa phần cứng lõi IP CORDIC (Coordinate Rotation Digital Computer) sử dụng ngôn ngữ Verilog HDL để tính toán các hàm lượng giác (Sin, Cos) và phép biến đổi vector. Thiết kế nhắm tới các ứng dụng thời gian thực như viễn thông số, xử lý tín hiệu radar, và điều khiển động cơ (FOC) bằng cách thay thế hoàn toàn bộ nhân (multiplier) bằng chuỗi các phép cộng/trừ (Add/Subtract) và dịch bit (Shift).

## 1. Thông số kỹ thuật và Hiệu năng
*   **Độ rộng dữ liệu:** 32-bit chuẩn số phẩy tĩnh (Fixed-Point). Tọa độ X, Y sử dụng định dạng Q2.29, trong khi trục góc Z được ánh xạ toàn dải 360° tương ứng với khoảng giá trị [-2^31, 2^31-1].
*   **Cấu trúc xử lý:** Áp dụng kỹ thuật đường ống (Pipeline) 24 tầng, bao gồm 1 tầng tiền xử lý, 20 tầng tính toán lõi CORDIC và 3 tầng hậu xử lý.
*   **Tần số hoạt động tối đa (Fmax):** 128.12 MHz, đáp ứng chu kỳ xung nhịp an toàn T_min ≈ 7.805 ns.
*   **Độ trễ hệ thống (Latency):** 24 chu kỳ xung nhịp.
*   **Chế độ hoạt động:** Hỗ trợ tính toán toàn dải 360° cho cả chế độ Xoay góc (Rotation mode) và Tìm góc (Vectoring mode).
*   **Độ chính xác:** Sai số ngõ ra đối với hàm lượng giác dao động ở mức 10^-5, và sai số góc không vượt quá 0.01°.

## 2. Kiến trúc Hệ thống
Hệ thống được thiết kế phân tầng, bao gồm 3 khối xử lý chính:
*   **Khối Tiền xử lý (Pre-processor):** Mở rộng dải hoạt động của CORDIC ra trọn vẹn 360° bằng cách lấy đối xứng góc để đưa dữ liệu về vùng hội tụ an toàn của lõi là góc phần tư thứ 1 và thứ 4 (khoảng [-90°, +90°]). Khối này xuất ra cờ trạng thái `invert_flag_d` để báo hiệu cho hệ thống biết trạng thái đảo trục tọa độ.
*   **Lõi CORDIC (CORDIC Core):** Bao gồm khối Điều khiển (Controller) quản lý đồng bộ thời gian và khối Datapath Top chứa 20 module Datapath đơn lẻ được nhân bản và ghép nối. Tại mỗi tầng, mạch tổ hợp kết hợp với hằng số biên độ dịch bit và giá trị góc lượng giác từ bảng tra (LUT) để thực hiện một bước xoay vector.
*   **Khối Hậu xử lý (Post-processor):** Thực hiện bù lại hệ số giãn K (≈ 0.60725) của thuật toán thông qua hai tầng tính toán cộng/trừ các lũy thừa của 2 nhằm tránh sử dụng bộ nhân cứng gây thắt cổ chai. Đồng thời, khối này tiến hành đảo chiều hoặc bù góc dựa trên cờ trạng thái `invert_i` từ khối Tiền xử lý để khôi phục kết quả về đúng góc phần tư ban đầu.

## 3. Tài nguyên Phần cứng
Đánh giá mức độ tiêu thụ tài nguyên phần cứng trên FPGA sau khi tổng hợp:
*   **Phần tử logic (Logic Elements):** Hệ thống sử dụng 3,546 LEs, chiếm khoảng 11% diện tích tài nguyên khả trình để xây dựng các bộ cộng/trừ 32-bit và mạch dịch bit.
*   **Thanh ghi (Dedicated Logic Registers):** Sử dụng 2,295 Flip-flops để chốt dữ liệu luân chuyển qua 24 tầng pipeline.
*   **Chân giao tiếp (I/O Pins):** Cần 198 chân vật lý (chiếm 42%) để phục vụ 6 bus dữ liệu 32-bit (cho X_i, Y_i, Z_i, X_o, Y_o, Z_o) cùng các tín hiệu điều khiển hệ thống (clk, enable, reset, valid_i, mode_i, valid_o).