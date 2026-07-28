//
//  ToastView.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//

import SwiftUI

struct ToastView: View {
  let toast: ToastMessage
  let onTap: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: toast.type.icon)
        .foregroundStyle(toast.type.color)
        .font(.title2)
        .fontWeight(.semibold)

      VStack(alignment: .leading, spacing: 4) {
        Text(toast.title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundStyle(Color.primary)

        if let message = toast.message {
          Text(message)
            .font(.subheadline)
            .foregroundStyle(Color.secondary)
        }
      }

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.granite.s50)
        .shadow(
          color: Color.black.opacity(0.1),
          radius: 8,
          x: 0,
          y: 4
        )
    )
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
    }
    .onTapGesture {
      onTap()
    }
  }
}

#Preview {
  VStack {
    ForEach(ToastType.allCases, id: \.self) { type in
      ToastView(
        toast: ToastMessage(
          title: "\(type)",
          message: "Your action was completed successfully",
          type: type,
          duration: 5.0
        ),
        onTap: {}
      )
    }
  }
  .padding(16)
}
