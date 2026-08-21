//
//  SingleSheetItemScreen.swift
//  Draft
//
//  Cách đúng: MỘT .sheet(item:) duy nhất, một enum quyết định sheet nào đang mở.
//
//  Hai cờ Bool độc lập cho phép biểu diễn trạng thái "cả hai cùng mở" — thứ mà
//  UIKit không làm được. Enum optional thì không: mở B tức là A phải đóng.
//
//  KẾT QUẢ ĐO (iOS 26.5): đổi activeSheet thì sheet hiện tại ẩn đi trước, xong
//  sheet mới mới hiện. Không có cross-fade.
//
//  Vì sao: UIKit không có API thay thế modal. Đổi identity buộc SwiftUI phải
//  dismiss(animated:) rồi present(animated:) — hai thao tác tuần tự, nên luôn
//  có khoảng trống ở giữa.
//
//  Hệ quả phải nhớ: onDismiss BẮN TRONG khoảng trống đó. Nếu code coi
//  onDismiss là "người dùng đã đóng hết" thì cú swap sẽ kích nhầm — phải guard
//  bằng cách kiểm tra item hiện tại còn nil hay không.
//
//  Muốn sheet chồng sheet thật sự thì không dùng cách này: present cái thứ hai
//  từ BÊN TRONG content của sheet thứ nhất (lúc đó host là VC của sheet A,
//  khác cửa), hoặc đẩy hẳn sang một UIWindow riêng.
//

import SwiftUI

enum LabSheetKind: String, Identifiable, CaseIterable {
  case a = "A"
  case b = "B"

  var id: String { rawValue }

  var tint: Color {
    switch self {
    case .a: .blue
    case .b: .orange
    }
  }
}

struct SingleSheetItemScreen: View {
  @State private var log = SheetEventLog()
  @State private var activeSheet: LabSheetKind?

  var body: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        @State private var activeSheet: LabSheetKind?

        List { … }
          .sheet(item: $activeSheet) { kind in … }
        """)
      }

      Section("Kịch bản") {
        Button("Mở A") {
          log.reset()
          setActive(.a)
        }

        Button("Mở B") {
          log.reset()
          setActive(.b)
        }

        Button("Mở A, 1,5s sau đổi sang B") {
          log.reset()
          setActive(.a)
          Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            setActive(.b)
          }
        }
      }

      Section("Trạng thái") {
        LabeledContent("activeSheet", value: activeSheet?.rawValue ?? "nil")
        Text("Chỉ có một biến, nên không thể rơi vào trạng thái hai sheet cùng bật.")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      SheetEventLogSection(log: log)
    }
    .navigationTitle("3. .sheet(item:)")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $activeSheet) { kind in
      LabSheetView(name: kind.rawValue, tint: kind.tint, log: log) {
        setActive(nil)
      }
    }
  }

  // MARK: - Actions

  private func setActive(_ kind: LabSheetKind?) {
    log.add("activeSheet = \(kind?.rawValue ?? "nil")")
    activeSheet = kind
  }
}

#Preview {
  NavigationStack {
    SingleSheetItemScreen()
  }
}
