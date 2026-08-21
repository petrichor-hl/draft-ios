//
//  SiblingSheetScreen.swift
//  Draft
//
//  Hai .sheet() gắn trên hai view ANH EM (hai nhánh khác nhau của cây view),
//  thay vì chồng lên nhau.
//
//  Giả thuyết cần kiểm chứng: "chồng nhau thì hỏng, tách anchor ra thì được".
//
//  KẾT QUẢ ĐO (iOS 26.5): giả thuyết sai — behavior giống hệt
//  ChainedSheetScreen. Vẫn một sheet tại một thời điểm, sheet thứ hai vẫn xếp
//  hàng chờ sheet thứ nhất đóng rồi mới bật lên.
//
//  Vì sao: SwiftUI không lấy view làm anchor. Nó đi ngược lên tìm presentation
//  host gần nhất, và hai nhánh anh em ở đây có chung một host — cùng cái
//  UIViewController đang chứa màn hình này. Tách nhánh không tách được cửa.
//

import SwiftUI

struct SiblingSheetScreen: View {
  @State private var log = SheetEventLog()
  @State private var isAPresented = false
  @State private var isBPresented = false

  var body: some View {
    VStack(spacing: 0) {
      // Nhánh 1 — giữ sheet A
      anchorBanner
        .sheet(isPresented: $isAPresented) {
          LabSheetView(name: "A", tint: .blue, log: log) { setA(false) }
        }

      // Nhánh 2 — giữ sheet B
      content
        .sheet(isPresented: $isBPresented) {
          LabSheetView(name: "B", tint: .orange, log: log) { setB(false) }
        }
    }
    .navigationTitle("2. Anh em")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Views

  private var anchorBanner: some View {
    HStack(spacing: 8) {
      Image(systemName: "rectangle.portrait.on.rectangle.portrait")
      Text("View này giữ .sheet A — List bên dưới giữ .sheet B")
    }
    .font(.footnote)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Color.blue.opacity(0.12))
  }

  private var content: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        VStack {
          banner.sheet(isPresented: $isAPresented) { A }
          list.sheet(isPresented: $isBPresented) { B }
        }
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
    SiblingSheetScreen()
  }
}
