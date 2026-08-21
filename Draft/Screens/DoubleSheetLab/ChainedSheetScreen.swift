//
//  ChainedSheetScreen.swift
//  Draft
//
//  Hai .sheet() gắn chồng lên CÙNG một view.
//
//  Đây là trường hợp hay gặp nhất khi refactor: mỗi lần thêm một sheet mới lại
//  nối thêm một .sheet vào cuối chuỗi modifier, và mọi thứ có vẻ vẫn chạy —
//  cho tới khi hai sheet muốn mở cùng lúc.
//
//  KẾT QUẢ ĐO (iOS 26.5): không crash, không warning, không có gì để grep.
//  Tại một thời điểm chỉ một sheet lên màn hình, và thứ quyết định KHÔNG phải
//  thứ tự gán state mà là VỊ TRÍ MODIFIER — cái gắn trước (nằm trong) luôn
//  thắng. Ở đây A là inner:
//
//    Mở A rồi B     -> A giữ chỗ, B xếp hàng, B lên khi A đóng.
//    Mở B rồi A     -> A GỠ B XUỐNG để chiếm chỗ. Cờ B vẫn true nên khi A
//                      đóng thì B được present LẠI.
//    Cùng một tick  -> A lên trước, bất kể setA/setB gọi theo thứ tự nào.
//
//  Nhật ký kịch bản "Mở B, 1,5s sau mở A":
//        0 ms  isBPresented = true
//       15 ms  Sheet B — onAppear
//     1633 ms  isAPresented = true
//     2184 ms  Sheet B — onDisappear   <- bị preempt, không phải xếp chồng
//     2200 ms  Sheet A — onAppear
//    29809 ms  Sheet B — onAppear      <- quay lại sau khi A đóng
//
//  Vì sao: vị trí trong cây view không tạo anchor riêng. Cả hai .sheet đều đi
//  ngược lên tìm presentation host gần nhất — cùng một UIViewController — mà
//  một VC chỉ có đúng một presentedViewController.
//
//  Hệ quả cho code thật: onAppear của sheet có thể bắn NHIỀU LẦN cho một lần
//  người dùng "mở". Đừng đặt analytics hay network call vào đó.
//
//  Đây là dạng bug khó chịu nhất vì nó im lặng: người dùng chỉ thấy một sheet
//  lạ tự nhảy ra sau khi đóng sheet đang xem. (SwiftUI đời iOS 14/15 còn tệ
//  hơn — nuốt luôn và cờ kẹt true vĩnh viễn.)
//
//  Gốc rễ là chỗ mô hình hoá dữ liệu, không phải chỗ modifier: hai Bool độc
//  lập biểu diễn được trạng thái "cả hai cùng mở", thứ mà UIKit không có.
//  Xem SingleSheetItemScreen.
//

import SwiftUI

struct ChainedSheetScreen: View {
  @State private var log = SheetEventLog()
  @State private var isAPresented = false
  @State private var isBPresented = false

  var body: some View {
    List {
      Section("Cách gắn") {
        SheetSourceSnippet(code: """
        List { … }
          .sheet(isPresented: $isAPresented) { A }
          .sheet(isPresented: $isBPresented) { B }
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

        // Chiều ngược lại: B là modifier NGOÀI. Nếu luật là "modifier trong
        // thắng" thì A sẽ gỡ B xuống để chiếm chỗ.
        Button("Mở B, 1,5s sau mở A (B vẫn đang present)") {
          log.reset()
          setB(true)
          Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            setA(true)
          }
        }
      }

      SheetEventLogSection(log: log)
    }
    .navigationTitle("1. Chồng nhau")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isAPresented) {
      LabSheetView(name: "A", tint: .blue, log: log) { setA(false) }
    }
    .sheet(isPresented: $isBPresented) {
      LabSheetView(name: "B", tint: .orange, log: log) { setB(false) }
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
    ChainedSheetScreen()
  }
}
