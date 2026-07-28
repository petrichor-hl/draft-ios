//
//  DemoToastFirstView.swift
//  Draft
//
//  Copied from FirstView in the MaverickToast prototype. The only change is the
//  missing outer NavigationStack: Draft pushes this screen onto the stack that
//  DraftApp already owns, so nesting another one would break the back button.
//

import SwiftUI

struct DemoToastFirstView: View {
  @State private var isSheetPresented = false
  @State private var stickyNoTapId: UUID?

  var body: some View {
    VStack {
      // Inline ToastView (rendered directly, not via the toast window).
      ToastView(
        toast: ToastMessage(
          title: "Inline Toast",
          message: "Rendered directly in FirstView.",
          type: .info,
          duration: nil
        ),
        onTap: {
          print("inline toast onTap")
        }
      )

      Spacer()

      Button {
        ToastManager.shared.showToast(
          .init(
            title: "Success!",
            message: "Your action was completed successfully",
            type: .success,
            duration: 5.0
          )
        )
      } label: {
        Text("Show Success Toast")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.green, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        ToastManager.shared.showToast(
          .init(
            title: "Error!",
            message: "Something went wrong. Please try again.",
            type: .error,
            duration: 5.0
          )
        )
      } label: {
        Text("Show Error Toast")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        ToastManager.shared.showToast(
          .init(
            title: "Warning!",
            message: "This action cannot be undone.",
            type: .warning,
            duration: 5.0
          )
        )
      } label: {
        Text("Show Warning Toast")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.yellow, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        ToastManager.shared.showToast(
          .init(
            title: "Info",
            message:
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian at St Bride Printing Library in London, took a 1914 Cicero translation and scrambled it to make dummy text for Letraset's Body Type sheets. It has survived not only many decades, but also the leap into electronic typesetting, remaining essentially unchanged.",
            type: .info,
            duration: 5.0
          )
        )
      } label: {
        Text("Show Info Toast")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        ToastManager.shared.showToast(
          .init(
            title: "Sticky!",
            message: "Stays until you tap it (duration = nil).",
            type: .warning,
            duration: nil
          )
        )
      } label: {
        Text("Show Sticky Toast")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.purple, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        stickyNoTapId = ToastManager.shared.showToast(
          .init(
            title: "Sticky (no tap close)",
            message: "Tap won't dismiss this (closeOnTap = false).",
            type: .error,
            duration: nil,
            closeOnTap: false
          )
        )
      } label: {
        Text("Sticky • no tap close")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.pink, in: RoundedRectangle(cornerRadius: 12))
      }

      Button {
        if let id = stickyNoTapId {
          ToastManager.shared.dismissToast(id)
          stickyNoTapId = nil
        }
      } label: {
        Text("Dismiss Sticky")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.gray.s500, in: RoundedRectangle(cornerRadius: 12))
      }

      NavigationLink("Go to Second View") {
        DemoToastSecondView()
      }

      Button {
        isSheetPresented = true
      } label: {
        Text("Show Bottom Sheet")
          .foregroundStyle(Color.white)
          .frame(width: 200, height: 40)
          .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
      }

      Spacer()
    }
    .padding()
    .navigationTitle("First View")
    .sheet(isPresented: $isSheetPresented) {
      VStack {
        Button {
          ToastManager.shared.showToast(
            .init(
              title: "Success!",
              message: "Your action was completed successfully",
              type: .success,
              duration: 5.0
            )
          )
        } label: {
          Text("Show Success Toast")
            .foregroundStyle(Color.white)
            .frame(width: 200, height: 40)
            .background(Color.green, in: RoundedRectangle(cornerRadius: 12))
        }

        Button {
          ToastManager.shared.showToast(
            .init(
              title: "Info",
              message:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam hendrerit sapien a egestas malesuada.",
              type: .info,
              duration: 5.0
            )
          )
        } label: {
          Text("Show Info Toast")
            .foregroundStyle(Color.white)
            .frame(width: 200, height: 40)
            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
        }

        Button {
          isSheetPresented = false
        } label: {
          Text("Close")
        }
      }
      .presentationDetents([.height(600)])
      .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  NavigationStack {
    DemoToastFirstView()
  }
}
