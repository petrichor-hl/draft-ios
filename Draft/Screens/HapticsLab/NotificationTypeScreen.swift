//
//  NotificationTypeScreen.swift
//  Draft
//
//  Generator C — UINotificationFeedbackGenerator.
//
//  Điểm cốt lõi: kiểu nằm ở LỜI GỌI chứ không ở init, nên chỉ cần
//  một instance. Đổi lại, mỗi cú rung kéo dài vài trăm ms và có
//  tiết tấu nhiều nhịp — rất dễ chồng lên nhau.
//

import SwiftUI
import UIKit

struct NotificationTypeScreen: View {
  @State private var generator = UINotificationFeedbackGenerator()
  @State private var isSpamming = false

  var body: some View {
    List {
      Section {
        ForEach(Self.types, id: \.name) { item in
          Button {
            generator.notificationOccurred(item.type)
          } label: {
            Text(".\(item.name)")
              .font(.system(.body, design: .monospaced))
          }
        }
      } header: {
        Text("3 loại")
      } footer: {
        Text("""
          Một instance dùng chung cho cả ba — khác Impact, ở đây kiểu là tham số của method.

          Bấm .error rồi bấm .success ngay sau để nghe rõ: mỗi loại là một CHUỖI nhịp có tiết tấu riêng, \
          không phải một cú tách đơn lẻ như Impact.
          """)
      }

      Section {
        Button {
          spamSuccess()
        } label: {
          Label(
            isSpamming ? "Đang bắn…" : "Bắn .success 5 lần liên tiếp",
            systemImage: "exclamationmark.triangle.fill"
          )
        }
        .disabled(isSpamming)
      } header: {
        Text("Vì sao không được lặp")
      } footer: {
        Text("""
          Năm cú success cách nhau 120ms. Vì mỗi cú kéo dài hơn khoảng cách đó, chúng đè lên nhau \
          thành một mớ ù ù vô nghĩa — người dùng không đếm được đã có mấy sự kiện.

          Kết luận: Notification chỉ dành cho KẾT QUẢ CUỐI của một tác vụ. Thao tác lặp lại nhiều lần \
          thì dùng Selection hoặc Impact.
          """)
      }
    }
    .navigationTitle("Notification")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func spamSuccess() {
    isSpamming = true
    Task {
      for _ in 0..<5 {
        generator.notificationOccurred(.success)
        try? await Task.sleep(for: .milliseconds(120))
      }
      isSpamming = false
    }
  }

  private static let types: [(name: String, type: UINotificationFeedbackGenerator.FeedbackType)] = [
    ("success", .success),
    ("warning", .warning),
    ("error", .error),
  ]
}

#Preview {
  NavigationStack {
    NotificationTypeScreen()
  }
}
