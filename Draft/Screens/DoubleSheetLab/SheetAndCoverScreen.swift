//
//  SheetAndCoverScreen.swift
//  Draft
//
//  Một .sheet() + một .fullScreenCover() trên cùng một view.
//
//  Đây là trường hợp thực tế nhất trong ba màn: một màn hình vừa có bottom
//  sheet chọn tuỳ chọn, vừa có full-screen flow (onboarding, paywall, camera).
//  Hai loại khác nhau nên rất dễ tưởng là hai kênh độc lập.
//
//  Ở đây thứ tự có thể quan trọng, nên test cả hai chiều: mở sheet trước rồi
//  cover, và mở cover trước rồi sheet.
//
//  KẾT QUẢ ĐO (iOS 26.5): vẫn một cửa duy nhất, luật vẫn là "modifier gắn
//  trước (nằm trong) thắng". Ở đây .sheet là inner:
//
//    Mở sheet rồi cover -> sheet giữ chỗ, cover xếp hàng.
//    Mở cover rồi sheet -> sheet GỠ cover xuống; đóng sheet thì cover lên lại.
//    Cùng một tick      -> sheet lên trước, dù setCover gọi trước hay sau.
//
//  CẨN THẬN đọc nhầm kịch bản "cover rồi sheet": nhìn thì tưởng sheet chồng
//  lên cover, nhưng phía sau sheet là List chứ không phải cover. Nhật ký:
//        0 ms  isCoverPresented = true
//       27 ms  Cover C — onAppear
//     1553 ms  isSheetPresented = true
//     2080 ms  Cover C — onDisappear   <- gỡ xuống TRƯỚC khi sheet lên
//     2082 ms  Sheet S — onAppear
//    18792 ms  Cover C — onAppear      <- present lại sau khi sheet đóng
//
//  Xem CoverAndSheetReversedScreen để biết vì sao luật là "inner thắng" chứ
//  không phải "sheet thắng cover".
//

import SwiftUI

struct SheetAndCoverScreen: View {
  @State private var log = SheetEventLog()
  @State private var isSheetPresented = false
  @State private var isCoverPresented = false

  var body: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        List { … }
          .sheet(isPresented: $isSheetPresented) { S }
          .fullScreenCover(isPresented: $isCoverPresented) { C }
        """)
      }

      Section("Kịch bản") {
        Button("Chỉ mở sheet") {
          log.reset()
          setSheet(true)
        }

        Button("Chỉ mở cover") {
          log.reset()
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

        Button("Mở cả hai trong cùng một tick") {
          log.reset()
          setCover(true)
          setSheet(true)
        }
      }

      SheetEventLogSection(log: log)
    }
    .navigationTitle("5. sheet + cover")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isSheetPresented) {
      LabSheetView(name: "S", tint: .blue, log: log) { setSheet(false) }
    }
    .fullScreenCover(isPresented: $isCoverPresented) {
      LabCoverView(name: "C", tint: .orange, log: log) { setCover(false) }
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
    SheetAndCoverScreen()
  }
}
