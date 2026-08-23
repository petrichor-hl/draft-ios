//
//  FixedSizeScreen.swift
//  Draft
//
//  PLACEHOLDER — chưa dựng demo.
//
//  Nhắc mình học .fixedSize(). Một số câu hỏi để bám vào khi làm:
//
//    • fixedSize() làm view bỏ qua kích thước cha đề nghị và lấy đúng
//      kích thước lý tưởng của chính nó. Vậy "kích thước lý tưởng" của
//      Text, Image, Shape lần lượt là gì?
//    • fixedSize(horizontal:vertical:) — khoá một chiều thôi thì sao?
//    • Vì sao nó hay được dùng để chữa Text bị cắt cụt hoặc bị xuống dòng
//      sớm, và khi nào cách đó phản tác dụng (chữ tràn ra ngoài màn hình)?
//    • Khác gì với .frame(width:height:) và .layoutPriority()?
//

import SwiftUI

struct FixedSizeScreen: View {
  var body: some View {
    List {
      Section {
        Text(".fixedSize()")
          .font(.system(.body, design: .monospaced))
        Text(".fixedSize(horizontal:vertical:)")
          .font(.system(.body, design: .monospaced))
      } header: {
        Text("Symbols")
      } footer: {
        Text("Chưa dựng demo — mở file để xem danh sách câu hỏi cần trả lời.")
      }
    }
    .navigationTitle(".fixedSize()")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    FixedSizeScreen()
  }
}
