//
//  GarminHeartRateScreen.swift
//  Draft
//
//  ĐỀ BÀI — dựng lại chart nhịp tim của Garmin Connect, màn "Dòng thời
//  gian hàng ngày". Khác hẳn Apple Health: Garmin vẽ ĐƯỜNG liền từ hàng
//  nghìn mẫu, Apple vẽ từng mẫu thành mark rời.
//
//  Đặc điểm đọc từ ảnh chụp:
//
//  1. LineMark dày đặc, răng cưa — mỗi mẫu một điểm, không gộp bucket.
//
//  2. Màu chạy theo GIÁ TRỊ Y, không phải theo nhóm: xanh dương ở vùng
//     thấp, lên lục, vàng, cam, rồi đỏ ở đỉnh 181. Đây là continuous
//     color scale — foregroundStyle(by:) với giá trị liên tục, cộng
//     chartForegroundStyleScale(range: Gradient(...)). Cần Basics #4.
//
//  3. Trục Y KHÔNG có số 0. Mốc 62 / 105 / 147 / 190, cách đều nhau 42–43
//     đơn vị. Nhịp tim người sống không về 0 nên để mặc định thì cả biểu
//     đồ dồn vào một phần ba trên. Cần chartYScale(domain:) — Basics #5.
//     CHƯA ĐO: 62 và 190 lấy từ đâu — min/max của ngày làm tròn, hay
//     biên zone cố định theo tuổi?
//
//  4. Đường ĐỨT ĐOẠN ở những giờ không đeo đồng hồ. LineMark mặc định nối
//     thẳng qua khoảng trống, nên phải tách segment bằng tham số series:.
//     Cần Types #4.
//
//  5. Trục X là dãy chấm tròn thay cho vạch chia, nhãn mỗi 4 giờ
//     (00, 04, 08, 12, 16, 20, 00). Chấm to nhỏ khác nhau. Dùng AxisMarks
//     với AxisValueLabel tự vẽ.
//
//  6. Nền tối, không có lưới dọc, lưới ngang mảnh.
//

import Charts
import SwiftUI

struct GarminHeartRateScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "waveform.path.ecg")
      .navigationTitle("Garmin — Nhịp tim")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    GarminHeartRateScreen()
  }
}
