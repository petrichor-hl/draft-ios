//
//  SnackBarView.swift
//  Draft
//

import SwiftUI

struct SnackBarView: View {
  let message: SnackBarMessage
  let onAction: () -> Void
  
  var body: some View {
    HStack(spacing: 16) {
      message.content
        .font(.subheadline)
        .foregroundStyle(Color.white)
      
      if let action = message.action {
        Spacer(minLength: 0)

        Button(action: onAction) {
          Text(action.label)
            .font(.subheadline.weight(.semibold))
            .underline()
            .foregroundStyle(Color.white)
        }
        .buttonStyle(.plain)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(Color.black)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
    )
  }
}
