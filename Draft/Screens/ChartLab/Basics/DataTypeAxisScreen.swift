//
//  DataTypeAxisScreen.swift
//  Draft
//
//  ĐỀ BÀI — cùng một tuần dữ liệu, đưa vào trục X bằng ba kiểu khác nhau:
//    String ("T2")  → band scale, mỗi giá trị một dải rộng bằng nhau
//    Int (2)        → linear scale, khoảng cách giữa các số có ý nghĩa
//    Date           → time scale, Charts tự chọn đơn vị nhãn theo locale
//
//  Câu hỏi đắt nhất: bỏ một ngày ra khỏi mảng thì chuyện gì xảy ra?
//  Band scale coi như ngày đó chưa từng tồn tại; linear và time để lại
//  đúng một khoảng trống. Đây là lý do chart nhịp tim phải dùng Date.
//

import Charts
import SwiftUI

struct DataTypeAxisScreen: View {
  var body: some View {
    ContentUnavailableView("Chưa làm", systemImage: "ruler")
      .navigationTitle("Kiểu dữ liệu → loại trục")
      .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    DataTypeAxisScreen()
  }
}
