//
//  FormAutofillScreen.swift
//  Draft
//
//  TODO — Username, password và mã OTP.
//  Kiểm tra autofill, viết hoa tự động và autocorrection theo loại dữ liệu.

import SwiftUI

struct FormAutofillScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Autofill")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormAutofillScreen()
    }
}
