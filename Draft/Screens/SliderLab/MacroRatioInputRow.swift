//
//  MacroRatioInputRow.swift
//  Draft
//
//  Ba phần trăm macro nằm cạnh nhau, mỗi cái dưới số gram tương ứng. Một cột ôm
//  cả hai nên hai con số không bao giờ lệch hàng nhau.
//
//  Clone từ dietfit-ios — Packages/Features/Sources/Profile/Components/
//  ProfileFields/MacroRatioInputRow.swift. Đổi: textStyle/DSIcon/token màu thay
//  bằng font và màu hệ thống, icon dùng SF Symbol (xem `MacroType.symbol`).
//

import SwiftUI

struct MacroRatioInputRow: View {
  let dailyCalories: Int
  let carb: Int
  let protein: Int
  let fat: Int

  var body: some View {
    HStack(alignment: .bottom, spacing: 12) {
      column(.carb, percent: carb)
      column(.protein, percent: protein)
      column(.fat, percent: fat)
    }
  }

  private func column(_ macro: MacroType, percent: Int) -> some View {
    VStack(spacing: 8) {
      grams(macro, percent: percent)
      box(percent)
    }
    .frame(maxWidth: .infinity)
  }

  private func grams(_ macro: MacroType, percent: Int) -> some View {
    HStack(spacing: 4) {
      Image(systemName: macro.symbol)
        .font(.caption)
        .foregroundStyle(macro.accentColor)

      // `Text(verbatim:)` chứ không nội suy thẳng: chuỗi có interpolation là
      // LocalizedStringKey, và ở locale vi thì 1000 thành "1.000".
      Text(verbatim: "\(macro.title) \(macro.grams(ofDailyCalories: dailyCalories, percent: percent))g")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
  }

  private func box(_ percent: Int) -> some View {
    HStack(spacing: 0) {
      Text(String(percent))
        .font(.title2.bold())
        .foregroundStyle(.primary)

      Text(verbatim: "%")
        .font(.body)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 56)
    .background(Color(.systemBackground), in: .rect(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.gray.s200, lineWidth: 1)
    }
  }
}

#Preview {
  MacroRatioInputRow(dailyCalories: 2000, carb: 45, protein: 35, fat: 20)
    .padding()
}
