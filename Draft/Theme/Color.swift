//
//  Color.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//
//  Lưu ý: `enum gray` che mất `Color.gray` của SwiftUI trong toàn app — dùng
//  `Color.gray.s500` thay cho `Color.gray` cũ.
//

import SwiftUI

extension Color {
  enum gray {
    static let s50 = Color(hex: "#F8F8F8")
    static let s100 = Color(hex: "#F1F0EF")
    static let s200 = Color(hex: "#E6E4E2")
    static let s300 = Color(hex: "#D4D0CD")
    static let s400 = Color(hex: "#B9B4B0")
    static let s500 = Color(hex: "#9F9893")
    static let s600 = Color(hex: "#87807B")
    static let s700 = Color(hex: "#706A65")
    static let s800 = Color(hex: "#5E5956")
    static let s900 = Color(hex: "#514E4B")
    static let s950 = Color(hex: "#2A2725")
  }

  enum granite {
    static let s50 = Color(hex: "#F8F8F8")
    static let s100 = Color(hex: "#F1F0EF")
    static let s200 = Color(hex: "#E6E4E2")
    static let s300 = Color(hex: "#D4D0CD")
    static let s400 = Color(hex: "#B9B4B0")
    static let s500 = Color(hex: "#9F9893")
    static let s600 = Color(hex: "#87807B")
    static let s700 = Color(hex: "#706A65")
    static let s800 = Color(hex: "#5E5956")
    static let s900 = Color(hex: "#514E4B")
    static let s950 = Color(hex: "#2A2725")
  }
}

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
