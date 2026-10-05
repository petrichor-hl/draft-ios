//
//  MaxHeightScrollScreen.swift
//  Draft
//
//  .frame(maxHeight: 400) trên ScrollView cho ra kết quả giống hệt
//  .frame(height: 400): khung luôn đúng 400pt.
//
//  Đo thật trên iPhone 17 Pro — content 60 / 300 / 360 / 660pt đều cho
//  khung 400pt, không lần nào co lại. Chặn trên thì đúng, co theo content
//  thì không bao giờ.
//
//  Lý do: maxHeight chỉ ĐỀ NGHỊ xuống ScrollView tối đa 400. ScrollView
//  tham lam trên trục scroll nên nhận trọn 400 rồi báo ngược lên 400.
//  Frame nhận số đó, kẹp vào [0, 400] → vẫn 400.
//
//  Muốn khung co theo content thì xem màn 5 (CappedHeightScrollScreen).
//

import SwiftUI

struct MaxHeightScrollScreen: View {
  private let rowHeight: CGFloat = 60
  private let capHeight: CGFloat = 400

  @State private var rowCount: Int = 5

  var body: some View {
    VStack(spacing: 16) {
      ScrollView {
        VStack(spacing: 0) {
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
      .frame(maxHeight: capHeight)
      .border(.red, width: 1)

      Stepper("Số row: \(rowCount)", value: $rowCount, in: 1...20)

      Text("Khi content height bên trong ScrollView lớn hơn ScrollView height thì mới scroll được.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)

      Spacer()
    }
    .padding()
    .navigationTitle("maxHeight 400pt")
    .navigationBarTitleDisplayMode(.inline)
  }
}
