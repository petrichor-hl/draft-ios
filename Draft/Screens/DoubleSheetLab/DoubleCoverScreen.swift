//
//  DoubleCoverScreen.swift
//  Draft
//
//  Hai .fullScreenCover() gắn chồng lên cùng một view.
//
//  Câu hỏi: .fullScreenCover có đi chung một cửa với .sheet không? Cả hai đều
//  quy về `present(_:animated:)` trên cùng một UIViewController, chỉ khác
//  modalPresentationStyle — nên dự đoán là giống hệt ChainedSheetScreen.
//
//  Khác biệt đáng để ý khi test: cover không có vuốt-để-đóng. Nếu SwiftUI xếp
//  hàng cover thứ hai, ta sẽ bị kẹt lại trong đó cho tới khi bấm nút Đóng.
//
//  KẾT QUẢ ĐO (iOS 26.5): giống hệt ChainedSheetScreen — dự đoán đúng.
//  "Mở A và B trong cùng một tick" -> Cover A (modifier trong) lên trước, đóng
//  A thì Cover B lên. Loại presentation không tạo ra kênh riêng: cover cũng chỉ
//  là present(_:animated:) với modalPresentationStyle khác.
//

import SwiftUI

struct DoubleCoverScreen: View {
  @State private var log = SheetEventLog()
  @State private var isAPresented = false
  @State private var isBPresented = false

  var body: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        List { … }
          .fullScreenCover(isPresented: $isAPresented) { A }
          .fullScreenCover(isPresented: $isBPresented) { B }
        """)
      }

      Section("Kịch bản") {
        Button("Chỉ mở A") {
          log.reset()
          setA(true)
        }

        Button("Chỉ mở B") {
          log.reset()
          setB(true)
        }

        Button("Mở A, 1,5s sau mở B (A vẫn đang present)") {
          log.reset()
          setA(true)
          Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            setB(true)
          }
        }

        Button("Mở A và B trong cùng một tick") {
          log.reset()
          setA(true)
          setB(true)
        }
      }

      SheetEventLogSection(log: log)
    }
    .navigationTitle("4. Hai fullScreenCover")
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(isPresented: $isAPresented) {
      LabCoverView(name: "A", tint: .blue, log: log) { setA(false) }
    }
    .fullScreenCover(isPresented: $isBPresented) {
      LabCoverView(name: "B", tint: .orange, log: log) { setB(false) }
    }
  }

  // MARK: - Actions

  private func setA(_ value: Bool) {
    log.add("isAPresented = \(value)")
    isAPresented = value
  }

  private func setB(_ value: Bool) {
    log.add("isBPresented = \(value)")
    isBPresented = value
  }
}

#Preview {
  NavigationStack {
    DoubleCoverScreen()
  }
}
