//
//  ReorderItem.swift
//  Draft
//
//  Dữ liệu và view dùng chung cho Reorder a List. Mỗi phần tử có icon và màu
//  riêng để mắt bắt được ngay cái nào vừa đổi chỗ.
//

import SwiftUI

struct ReorderItem: Identifiable {
  let id = UUID()
  let name: String
  let symbol: String
  let tint: Color
  var isPinned = false

  static let samples: [ReorderItem] = [
    ReorderItem(name: "Sun", symbol: "sun.max.fill", tint: .orange),
    ReorderItem(name: "Moon", symbol: "moon.fill", tint: .indigo),
    ReorderItem(name: "Cloud", symbol: "cloud.fill", tint: .cyan),
    ReorderItem(name: "Bolt", symbol: "bolt.fill", tint: .yellow),
    ReorderItem(name: "Leaf", symbol: "leaf.fill", tint: .green),
    ReorderItem(name: "Flame", symbol: "flame.fill", tint: .red)
  ]

  /// Giống `samples` nhưng hai phần tử đầu được ghim — dùng ở mục 3.
  static let pinnedSamples: [ReorderItem] = samples.enumerated().map { offset, item in
    var item = item
    item.isPinned = offset < 2
    return item
  }
}

// MARK: - Hàng

struct ReorderItemRow: View {
  let item: ReorderItem

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: item.symbol)
        .font(.body.weight(.semibold))
        .foregroundStyle(.white)
        .frame(width: 32, height: 32)
        .background(item.tint.gradient, in: .rect(cornerRadius: 8))

      Text(item.name)

      if item.isPinned {
        Image(systemName: "pin.fill")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

// MARK: - Ghi chú

struct ReorderNote: View {
  let title: LocalizedStringKey
  let text: LocalizedStringKey

  init(_ title: LocalizedStringKey, _ text: LocalizedStringKey) {
    self.title = title
    self.text = text
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.caption.weight(.semibold))
      Text(text).font(.caption).foregroundStyle(.secondary)
    }
  }
}
