//
//  MaxHeightInSheetScreen.swift
//  Draft
//
//  Màn 6 kết luận: .frame(maxHeight: 400) cho ra khung luôn đúng 400pt,
//  giống hệt .frame(height: 400). Kết luận đó CHỈ ĐÚNG khi chỗ được đề
//  nghị còn ≥ 400pt — điều luôn thoả trên một màn hình đầy.
//
//  Màn này bóp chỗ trống lại để phá giả định đó: sheet detent 650pt, bên
//  trong có TextField. Bàn phím lên, iOS phải co sheet cho detent cộng
//  bàn phím không vượt chiều cao màn. Sheet co thì chỗ đề nghị xuống
//  ScrollView tụt dưới 400, và khung co theo.
//
//  Đó mới là khác biệt thật giữa hai modifier:
//    .frame(height: 400)     — cứng 400, chỗ chật thì tràn.
//    .frame(maxHeight: 400)  — min(chỗ được đề nghị, 400).
//

import SwiftUI

struct MaxHeightInSheetScreen: View {
  @State private var isPresented = false

  var body: some View {
    VStack(spacing: 16) {
      Button("Mở sheet 650pt") {
        isPresented = true
      }
      .buttonStyle(.borderedProminent)

      Text("Mở sheet, xem viền đỏ đang ở 400pt. Chạm TextField để bật bàn phím rồi nhìn lại viền đỏ.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Spacer()
    }
    .padding()
    .navigationTitle("maxHeight trong sheet")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isPresented) {
      SheetBody()
    }
  }
}

private struct SheetBody: View {
  private let rowHeight: CGFloat = 60
  private let capHeight: CGFloat = 400
  // Dùng chung cho clipShape và overlay: hai chỗ phải khớp nhau.
  private let cornerRadius: CGFloat = 20

  private let rowRange = 1...20

  // 5 row = 300pt
  @State private var rowCount: Int = 5
  @State private var text = ""

  // Stepper của SwiftUI lệch hàng khi chiều cao bị bóp (bàn phím co sheet):
  // nhãn và cụm nút tách rời nhau ~17pt. Dựng lại bằng HStack thuần.
  private var rowStepper: some View {
    HStack {
      Text("Số row: \(rowCount)")

      Spacer()

      Button {
        rowCount -= 1
      } label: {
        Image(systemName: "minus")
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.bordered)
      .disabled(rowCount <= rowRange.lowerBound)

      Button {
        rowCount += 1
      } label: {
        Image(systemName: "plus")
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.bordered)
      .disabled(rowCount >= rowRange.upperBound)
    }
  }

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
      .clipShape(.rect(cornerRadius: cornerRadius))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius)
          .strokeBorder(Color.red, lineWidth: 1)
      }

      rowStepper

      Text("Khi content height bên trong ScrollView lớn hơn ScrollView height thì mới scroll được.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)

      TextField("Chạm để bật bàn phím", text: $text)
        .textFieldStyle(.roundedBorder)
      
      
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding()
    .presentationDetents([.height(650)])
    .presentationDragIndicator(.visible)
  }
}
