//
//  FormNextFocusScreen.swift
//  Draft
//
//  TODO — Next chuyển sang ô thứ hai và đưa ô đó vào vùng nhìn thấy.
//  Done ở ô cuối kết thúc nhập; thử cả bàn phím ngoài.

import SwiftUI

struct FormNextFocusScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Next / Done")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormNextFocusScreen()
    }
}
