//
//  MacroType.swift
//  Draft
//
//  Ba macro và những thứ đi kèm: tên, icon, màu, hệ số calo.
//
//  Clone từ dietfit-ios — Packages/Features/Sources/Utils/MacroType.swift. Bản
//  gốc còn ba bộ màu cũ đang chờ khai tử và phần gợi ý ăn uống; ở đây chỉ giữ
//  đúng những gì thanh chia macro cần.
//

import SwiftUI

enum MacroType {
  case carb
  case protein
  case fat

  var title: String {
    switch self {
    case .carb: "Carb"
    case .protein: "Protein"
    case .fat: "Fat"
    }
  }

  /// SF Symbol thay cho bộ icon riêng của Dietfit — Draft không có asset đó.
  var symbol: String {
    switch self {
    case .carb: "leaf.fill"
    case .protein: "fork.knife"
    case .fat: "drop.fill"
    }
  }

  /// Giữ nguyên hex của Dietfit (wood 400 / tomato 400 / orange 300): màu ở đây
  /// mang nghĩa, đổi màu là đổi cách đọc thanh.
  var accentColor: Color {
    switch self {
    case .carb: Color(hex: "#CB9B6C")
    case .protein: Color(hex: "#FD856C")
    case .fat: Color(hex: "#FDBA74")
    }
  }

  /// Hệ số Atwater — 1g carb hay đạm là 4 kcal, 1g béo là 9 kcal.
  var caloriesPerGram: Int {
    switch self {
    case .carb, .protein: 4
    case .fat: 9
    }
  }

  func grams(ofDailyCalories calories: Int, percent: Int) -> Int {
    Int((Double(calories) * Double(percent) / 100 / Double(caloriesPerGram)).rounded())
  }
}

/// `init(hex:)` ở Theme/Color.swift để `private` nên không với sang file khác
/// được. Khai báo lại ở đây cũng `private`: hai bản file-private cùng chữ ký
/// nằm ở hai file khác nhau thì không đụng nhau.
private extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r = Double((int >> 16) & 0xFF) / 255
    let g = Double((int >> 8) & 0xFF) / 255
    let b = Double(int & 0xFF) / 255
    self.init(red: r, green: g, blue: b)
  }
}
