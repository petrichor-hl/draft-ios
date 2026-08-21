//
//  CoverAndSheetReversedScreen.swift
//  Draft
//
//  Giống SheetAndCoverScreen nhưng ĐẢO THỨ TỰ MODIFIER: .fullScreenCover gắn
//  trước (nằm trong), .sheet gắn sau (nằm ngoài).
//
//  Đây là phép thử để tách hai giả thuyết mà màn 5 không phân biệt được:
//
//    H1 — modifier nằm TRONG được ưu tiên (thứ tự trong code quyết định)
//    H2 — .sheet luôn thắng .fullScreenCover (loại quyết định)
//
//  Ở màn 5, .sheet vừa là inner vừa là sheet nên cả hai giả thuyết cùng đúng.
//  Ở đây cover mới là inner. Bấm "Mở cả hai trong cùng một tick":
//
//    - Cover lên trước  -> H1 đúng, thứ tự modifier là thứ quyết định.
//    - Sheet lên trước  -> H2 đúng, loại presentation mới là thứ quyết định.
//
//  KẾT QUẢ ĐO (iOS 26.5): H1 ĐÚNG, H2 SAI.
//  "Mở cả hai trong cùng một tick" -> Cover C lên trước, dù setSheet(true)
//  chạy TRƯỚC setCover(true) trong cùng hàm. Đóng cover thì Sheet S lên.
//
//  Kết luận cuối: cái quyết định là thứ tự modifier trong code. Loại
//  presentation không liên quan, thứ tự gán state cũng không.
//

import SwiftUI

struct CoverAndSheetReversedScreen: View {
  @State private var log = SheetEventLog()
  @State private var isSheetPresented = false
  @State private var isCoverPresented = false

  var body: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        List { … }
          .fullScreenCover(isPresented: $isCoverPresented) { C }
          .sheet(isPresented: $isSheetPresented) { S }
        """)
      }

      Section("Kịch bản") {
        Button("Mở cả hai trong cùng một tick") {
          log.reset()
          setSheet(true)
          setCover(true)
        }

        Button("Mở sheet, 1,5s sau mở cover") {
          log.reset()
          setSheet(true)
          Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            setCover(true)
          }
        }

        Button("Mở cover, 1,5s sau mở sheet") {
          log.reset()
          setCover(true)
          Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            setSheet(true)
          }
        }
      }

      SheetEventLogSection(log: log)
    }
    .navigationTitle("6. Đảo thứ tự")
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(isPresented: $isCoverPresented) {
      LabCoverView(name: "C", tint: .orange, log: log) { setCover(false) }
    }
    .sheet(isPresented: $isSheetPresented) {
      LabSheetView(name: "S", tint: .blue, log: log) { setSheet(false) }
    }
  }

  // MARK: - Actions

  private func setSheet(_ value: Bool) {
    log.add("isSheetPresented = \(value)")
    isSheetPresented = value
  }

  private func setCover(_ value: Bool) {
    log.add("isCoverPresented = \(value)")
    isCoverPresented = value
  }
}

#Preview {
  NavigationStack {
    CoverAndSheetReversedScreen()
  }
}
