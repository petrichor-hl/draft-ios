//
//  ImpactStyleScreen.swift
//  Draft
//
//  Generator B — UIImpactFeedbackGenerator.
//
//  Điểm cốt lõi: style chốt ở INIT, nên mỗi style cần một instance riêng.
//

import SwiftUI
import UIKit

struct ImpactStyleScreen: View {
  @State private var bank = ImpactBank()
  @State private var intensity: Double = 1.0

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text("intensity")
            Spacer()
            Text(intensity, format: .number.precision(.fractionLength(2)))
              .monospacedDigit()
              .foregroundStyle(.secondary)
          }
          Slider(value: $intensity, in: 0...1)
        }
        .padding(.vertical, 4)
      } footer: {
        Text("intensity là HỆ SỐ NHÂN lên preset, không phải trục độc lập. Kéo về 0 thì mọi nút bên dưới im hoàn toàn.")
      }

      Section {
        ForEach(Self.styles, id: \.name) { item in
          Button {
            bank.generator(for: item.style)
              .impactOccurred(intensity: CGFloat(intensity))
          } label: {
            Text(".\(item.name)")
              .font(.system(.body, design: .monospaced))
          }
        }
      } header: {
        Text("5 style")
      } footer: {
        Text("""
          Ở tầng UIKit cả năm nằm chung MỘT enum. Lên SwiftUI, Apple tách thành hai overload: \
          light/medium/heavy thành `weight`, soft/rigid thành `flexibility`. Cùng phần cứng, khác cách gọi tên.

          Đối chiếu chéo: mở màn SensoryFeedback, bấm .impact(weight: .heavy) ở intensity 1.00, \
          rồi quay lại đây bấm .heavy ở 1.00 — y hệt nhau.
          """)
      }
    }
    .navigationTitle("Impact")
    .navigationBarTitleDisplayMode(.inline)
  }

  private static let styles: [(name: String, style: UIImpactFeedbackGenerator.FeedbackStyle)] = [
    ("light", .light),
    ("medium", .medium),
    ("heavy", .heavy),
    ("soft", .soft),
    ("rigid", .rigid),
  ]
}

@MainActor
private final class ImpactBank {
  private let light = UIImpactFeedbackGenerator(style: .light)
  private let medium = UIImpactFeedbackGenerator(style: .medium)
  private let heavy = UIImpactFeedbackGenerator(style: .heavy)
  private let soft = UIImpactFeedbackGenerator(style: .soft)
  private let rigid = UIImpactFeedbackGenerator(style: .rigid)

  func generator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
    switch style {
    case .light: light
    case .medium: medium
    case .heavy: heavy
    case .soft: soft
    case .rigid: rigid
    @unknown default: medium
    }
  }
}
