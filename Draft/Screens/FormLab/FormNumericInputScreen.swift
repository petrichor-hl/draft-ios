//
//  FormNumericInputScreen.swift
//  Draft
//
//  TODO — Chỉ nhận số, kiểm tra cả gõ, paste và bàn phím ngoài.
//  Xác định trước: số nguyên hay thập phân, có cho phép dấu âm không.

import SwiftUI

struct FormNumericInputScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Numeric input")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormNumericInputScreen()
    }
}
