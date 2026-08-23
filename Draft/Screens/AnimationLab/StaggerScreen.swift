//
//  StaggerScreen.swift
//  Draft
//
//  Xếp hàng (stagger): nhiều phần tử cùng chạy một animation, nhưng mỗi
//  phần tử bắt đầu trễ hơn phần tử trước một nhịp.
//
//  Toàn bộ kỹ thuật nằm ở một dòng:
//
//      spring.delay(Double(index) * stagger)
//
//  Không cần Timer, không cần state riêng cho từng phần tử, không cần
//  Task.sleep. Chỉ là cùng một Animation được dời điểm xuất phát.
//
//  Tách ra từ FABSeparateDialogScreen.
//

import SwiftUI

struct StaggerScreen: View {
  @State private var isShown = false

  @State private var stagger: Double = 0.06
  @State private var order: Order = .topDown

  /// Chỉ để soi bằng mắt. 0.4s là quá nhanh để thấy được thứ tự.
  @State private var speed: Double = 1

  private let count = 6
  private let slide: CGFloat = 24

  private var spring: Animation {
    Animation.spring(duration: 0.4, bounce: 0.3).speed(speed)
  }

  var body: some View {
    VStack(spacing: 0) {
      stage
      controls
    }
    .navigationTitle("Stagger")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: - Sân khấu

  private var stage: some View {
    VStack(spacing: 10) {
      ForEach(0..<count, id: \.self) { index in
        card(index)
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  private func card(_ index: Int) -> some View {
    HStack {
      Text("Hàng \(index + 1)")
        .font(.headline)
      Spacer()
      Text(String(format: "trễ %.0f ms", delay(index) * 1000))
        .font(.caption)
        .monospacedDigit()
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 16)
    .frame(height: 52)
    .background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    // Hai giá trị nội suy được, không dùng transition — xem lý do ở
    // FABSeparateDialogScreen.
    .offset(y: isShown ? 0 : slide)
    .opacity(isShown ? 1 : 0)
    .animation(animation(index), value: isShown)
  }

  // MARK: - Chỗ tính nhịp

  /// Phần tử thứ `index` chờ bao lâu trước khi bắt đầu.
  private func delay(_ index: Int) -> Double {
    let step: Double
    switch order {
    case .topDown:
      step = Double(index)
    case .bottomUp:
      step = Double(count - 1 - index)
    }
    // Chia cho speed vì .delay nằm NGOÀI .speed nên không co giãn theo nó.
    // Thiếu phép chia này thì lúc xem chậm, các hàng vẫn nối nhau y như cũ
    // và không quan sát được thứ tự.
    return step * stagger / speed
  }

  private func animation(_ index: Int) -> Animation {
    isShown
      ? spring.delay(delay(index))
      // Lúc ẩn thì KHÔNG xếp hàng. Người dùng đã quyết xong, bắt họ ngồi
      // xem từng hàng lần lượt biến mất chỉ tổ chậm.
      : spring.speed(1.4)
  }

  // MARK: - Bảng điều khiển

  private var controls: some View {
    VStack(spacing: 10) {
      HStack(spacing: 12) {
        Button(isShown ? "Ẩn" : "Hiện") {
          withAnimation { isShown.toggle() }
        }
        .buttonStyle(.borderedProminent)

        Picker("Thứ tự", selection: $order) {
          ForEach(Order.allCases) { order in
            Text(order.label).tag(order)
          }
        }
        .pickerStyle(.menu)
      }

      slider("stagger", value: $stagger, range: 0...0.2, unit: "s")
      slider("tốc độ", value: $speed, range: 0.1...1, unit: "×")

      Text(note)
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
    .background(.bar)
  }

  private var note: String {
    stagger == 0
      ? "stagger = 0: tất cả chạy cùng lúc. Đây chính là đối chứng — kéo lên chút xíu là thấy khác ngay."
      : "Kéo tốc độ về 0.2 rồi bấm Hiện để nhìn rõ thứ tự. Trên 0.12s mỗi nhịp là bắt đầu có cảm giác lề mề."
  }

  private func slider(_ name: String, value: Binding<Double>,
                      range: ClosedRange<Double>, unit: String) -> some View {
    HStack(spacing: 10) {
      Text(name)
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(width: 52, alignment: .leading)
      Slider(value: value, in: range)
      Text("\(value.wrappedValue, format: .number.precision(.fractionLength(2)))\(unit)")
        .font(.caption)
        .monospacedDigit()
        .foregroundStyle(.secondary)
        .frame(width: 52, alignment: .trailing)
    }
  }

  enum Order: String, CaseIterable, Identifiable {
    case topDown, bottomUp

    var id: Self { self }

    var label: String {
      switch self {
      case .topDown:  "trên → dưới"
      case .bottomUp: "dưới → trên"
      }
    }
  }
}

#Preview {
  NavigationStack {
    StaggerScreen()
  }
}
