//
//  FixedHeightScrollScreen.swift
//  Draft
//
//  Case A — khung LUÔN cao đúng 400pt.
//  .frame(height: 400) ghim bounds.height, contentSize vẫn là chiều cao
//  thật của content → UIKit tự quyết định có scroll hay không.
//  Content ngắn hơn 400 thì dư khoảng trống bên dưới.
//
//  Bẫy: content ngắn vẫn "nhúc nhích" khi vuốt — đó là bounce, không phải
//  scroll. Tắt bằng .scrollBounceBehavior(.basedOnSize).
//

import SwiftUI

struct FixedHeightScrollScreen: View {
  private let rowHeight: CGFloat = 60
  @State private var rowCount: Int = 5

  private let boxHeight: CGFloat = 400

  private var contentHeight: CGFloat {
    CGFloat(rowCount) * rowHeight
  }

  private var canScroll: Bool {
    contentHeight > boxHeight
  }

  var body: some View {
    VStack(spacing: 16) {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(0..<rowCount, id: \.self) { index in
            Text("Row \(index)")
              .frame(maxWidth: .infinity)
              .frame(height: rowHeight)
              .background(index.isMultiple(of: 2) ? Color.blue.opacity(0.25)
                                                  : Color.blue.opacity(0.45))
          }
        }
      }
      .scrollBounceBehavior(.basedOnSize, axes: .vertical)
      .frame(height: boxHeight)
      .border(.red, width: 1)

      VStack(alignment: .leading, spacing: 8) {
        Stepper("Số row: \(rowCount)", value: $rowCount, in: 1...20)

        HStack {
          Text("content \(Int(contentHeight))pt / khung \(Int(boxHeight))pt")
          Spacer()
          Text(canScroll ? "SCROLL ĐƯỢC" : "KHÔNG SCROLL")
            .foregroundStyle(canScroll ? Color.green : Color.secondary)
        }
        .font(.footnote.monospacedDigit())
      }

      Spacer()
    }
    .padding()
    .navigationTitle("A. Fixed 400pt")
    .navigationBarTitleDisplayMode(.inline)
  }
}
