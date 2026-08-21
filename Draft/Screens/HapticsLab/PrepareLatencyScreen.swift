//
//  PrepareLatencyScreen.swift
//  Draft
//
//  Generator A — đo ĐỘ TRỄ của Taptic Engine bằng chính ngón tay.
//
//  Đây là màn duy nhất trong cả lab mà bạn kiểm chứng được bằng giác quan
//  chứ không phải bằng cách đọc tài liệu.
//

import SwiftUI
import UIKit

struct PrepareLatencyScreen: View {
  // Hai instance RIÊNG BIỆT, cùng style, khác nhau duy nhất ở chỗ
  // có được prepare() hay không. Giữ trong @State để chúng sống
  // suốt vòng đời màn hình — instance chết thì prepare() vô nghĩa.
  @State private var coldGenerator = UIImpactFeedbackGenerator(style: .heavy)
  @State private var warmGenerator = UIImpactFeedbackGenerator(style: .heavy)

  // Mốc thời gian lần rung gần nhất, để biết engine đã kịp ngủ lại chưa.
  @State private var lastFireDate = Date.distantPast

  // Chặn prepare() bị gọi lặp: onChanged bắn rất nhiều lần trong một cú kéo.
  @State private var didPrepareThisTouch = false

  var body: some View {
    List {
      engineStateSection
      abTestSection
      manualPrepareSection
    }
    .navigationTitle("prepare()")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Đồng hồ: engine đang nóng hay đã nguội?

  private var engineStateSection: some View {
    Section {
      TimelineView(.periodic(from: .now, by: 0.1)) { context in
        let elapsed = context.date.timeIntervalSince(lastFireDate)

        if elapsed > 900 {
          Label("Chưa rung lần nào — engine đang lạnh", systemImage: "snowflake")
            .foregroundStyle(.blue)
        } else if elapsed < 3 {
          Label {
            Text("Engine còn nóng — chờ \(3 - elapsed, format: .number.precision(.fractionLength(1)))s")
              .monospacedDigit()
          } icon: {
            Image(systemName: "flame.fill")
          }
          .foregroundStyle(.orange)
        } else {
          Label("Engine đã nguội — sẵn sàng thử", systemImage: "snowflake")
            .foregroundStyle(.blue)
        }
      }
    } header: {
      Text("Trạng thái engine")
    } footer: {
      Text("Taptic Engine tự ngủ sau khoảng 1–2 giây không dùng (Apple không công bố con số chính xác). Mốc 3s ở đây là để chắc chắn nó đã ngủ hẳn.")
    }
  }

  // MARK: - A/B: cùng một gesture, khác nhau đúng một dòng prepare()

  private var abTestSection: some View {
    Section {
      tapPad(title: "Lạnh — không prepare()",
             subtitle: "impactOccurred() gọi thẳng khi nhấc ngón",
             tint: .blue,
             onTouchDown: {
               // cố tình KHÔNG làm gì
             },
             onTouchUp: {
               coldGenerator.impactOccurred()
               lastFireDate = .now
             })

      tapPad(title: "Ấm — prepare() lúc ngón chạm",
             subtitle: "prepare() ở touch-down, impactOccurred() ở touch-up",
             tint: .orange,
             onTouchDown: {
               warmGenerator.prepare()
             },
             onTouchUp: {
               warmGenerator.impactOccurred()
               lastFireDate = .now
             })
    } header: {
      Text("Cold vs Warm")
    } footer: {
      Text("""
        Cách thử: chờ ô trên báo "đã nguội", bấm ô Lạnh — cú rung đến hơi trễ so với lúc ngón nhấc. \
        Chờ nguội lại, bấm ô Ấm — rung khớp đúng khoảnh khắc nhấc ngón.

        Cả hai ô dùng CHUNG một loại gesture và cùng bắn ở touch-up, nên khác biệt duy nhất là dòng prepare(). \
        Khoảng 80–150ms giữa lúc ngón chạm và lúc nhấc chính là cửa sổ để engine kịp khởi động.

        Bấm ô Lạnh HAI lần liên tiếp thì lần hai cũng dứt khoát — vì cú rung thứ nhất đã đánh thức engine. \
        Đó không phải lỗi demo, đó chính là cơ chế đang chạy.
        """)
    }
  }

  // MARK: - Chứng minh cửa sổ giữ nóng sẽ hết hạn

  private var manualPrepareSection: some View {
    Section {
      Button {
        coldGenerator.prepare()
      } label: {
        Label("Gọi prepare() ngay bây giờ", systemImage: "bolt.fill")
      }
    } header: {
      Text("Cửa sổ giữ nóng")
    } footer: {
      Text("""
        Bấm nút này rồi bấm NGAY ô "Lạnh" ở trên — nó sẽ rung dứt khoát như ô Ấm, \
        vì cùng dùng chung coldGenerator và engine vừa được đánh thức.

        Làm lại: bấm nút này, đếm thầm 5 giây, rồi mới bấm ô "Lạnh" — độ trễ quay lại. \
        Đó là lúc cửa sổ giữ nóng đã hết hạn.
        """)
    }
  }

  // MARK: - Helper

  // Một ô chạm. Dùng DragGesture(minimumDistance: 0) thay cho Button
  // vì cần TÁCH BẠCH hai thời điểm: ngón chạm xuống và ngón nhấc lên.
  // Button chỉ cho ta một callback duy nhất nên không đặt prepare() đúng chỗ được.
  private func tapPad(
    title: String,
    subtitle: String,
    tint: Color,
    onTouchDown: @escaping () -> Void,
    onTouchUp: @escaping () -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title).font(.headline)
      Text(subtitle)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 14)
    .contentShape(Rectangle())
    .listRowBackground(tint.opacity(0.12))
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          guard !didPrepareThisTouch else { return }
          didPrepareThisTouch = true
          onTouchDown()
        }
        .onEnded { _ in
          didPrepareThisTouch = false
          onTouchUp()
        }
    )
  }
}

#Preview {
  NavigationStack {
    PrepareLatencyScreen()
  }
}
