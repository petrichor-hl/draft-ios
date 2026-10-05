//
//  CappedHeightScrollScreen.swift
//  Draft
//
//  Case B — khung CO theo content, chặn trên ở 400pt.
//  .frame(maxHeight: 400) KHÔNG làm được việc này: ScrollView tham lam
//  trên trục scroll, nhận trọn 400 được đề nghị rồi báo ngược lên 400.
//  Phải đo chiều cao content trước, rồi .frame(height: min(đo được, 400)).
//

import SwiftUI

struct CappedHeightScrollScreen: View {
  private let rowHeight: CGFloat = 60
  private let capHeight: CGFloat = 400

  @State private var rowCount: Int = 5
  @State private var contentHeight: CGFloat = 0

  // Chiều cao thật sự áp cho khung: co theo content nhưng không vượt cap.
  private var boxHeight: CGFloat {
    min(contentHeight, capHeight)
  }

  private var canScroll: Bool {
    contentHeight > capHeight
  }

  var body: some View {
    VStack(spacing: 16) {
      ScrollView {
        // VStack chứ không LazyVStack: cần bố trí đủ mọi row thì số đo
        // mới là chiều cao toàn bộ content.
        VStack(spacing: 0) {
          ForEach(0..<rowCount, id: \.self) { index in
            Text("Row \(index)")
              .frame(maxWidth: .infinity)
              .frame(height: rowHeight)
              .background(index.isMultiple(of: 2) ? Color.blue.opacity(0.25)
                                                  : Color.blue.opacity(0.45))
          }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
          proxy.size.height
        } action: { newValue in
          contentHeight = newValue
        }
      }
      .scrollBounceBehavior(.basedOnSize, axes: .vertical)
      .frame(height: boxHeight)
      .border(.red, width: 1)

      VStack(alignment: .leading, spacing: 8) {
        Stepper("Số row: \(rowCount)", value: $rowCount, in: 1...20)

        HStack {
          Text("đo \(Int(contentHeight))pt → khung \(Int(boxHeight))pt")
          Spacer()
          Text(canScroll ? "CHẠM CAP" : "CO THEO CONTENT")
            .foregroundStyle(canScroll ? Color.green : Color.secondary)
        }
        .font(.footnote.monospacedDigit())
      }

      Spacer()
    }
    .padding()
    .navigationTitle("B. Cap 400pt")
    .navigationBarTitleDisplayMode(.inline)
  }
}
