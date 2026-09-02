//
//  AppendixView.swift
//  Draft
//

import SwiftUI

struct AppendixView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.scrollViewSafeArea)
            } label: {
                Text("ScrollView & Safe Area")
            }

            Button {
                coordinator.push(.contentMarginsPlayground)
            } label: {
                Text("contentMargins Playground")
            }

            Button {
                coordinator.push(.fixedHeightBottomSheet)
            } label: {
                Text("Fixed Height Bottom Sheet")
            }

            Button {
                coordinator.push(.dynamicHeightBottomSheet)
            } label: {
                Text("Dynamic Height Bottom Sheet iOS 16+")
            }

            Button {
                coordinator.push(.dynamicHeightBottomSheetiOS18)
            } label: {
                Text("Dynamic Height Bottom Sheet iOS 18+")
            }

            Button {
                coordinator.push(.localizeDaytime)
            } label: {
                Text("Localize Datetime")
            }

            Button {
                coordinator.push(.canonicalValue)
            } label: {
                Text("Learn Canonical Value")
            }

            Button {
                coordinator.push(.fullScreenCover)
            } label: {
                Text("Full-Screen Cover")
            }

            Button {
                coordinator.push(.learnVideo)
            } label: {
                Text("Learn VideoPlayer")
            }

            Button {
                coordinator.push(.learnPhotoPicker)
            } label: {
                Text("Learn PhotoPicker")
            }

            Button {
                coordinator.push(.keyboardLab)
            } label: {
                Text("Keyboard Lab")
            }

            Button {
                coordinator.push(.sideMenuLab)
            } label: {
                Text("Side Menu Lab")
            }

            Button {
                coordinator.push(.markdownLab)
            } label: {
                Text("Markdown Lab")
            }

            Button {
                coordinator.push(.learnAnimation)
            } label: {
                Text("Learn Animation")
            }

            Button {
                coordinator.push(.lineHeightExact)
            } label: {
                Text(".lineHeight(.exact) - iOS 26")
            }

            Button {
                coordinator.push(.observationLab)
            } label: {
                Text("Observation Lab: @Observable vs ObservableObject")
            }

            Button {
                coordinator.push(.snackBarLab)
            } label: {
                Text("SnackBar Lab")
            }

            Button {
                coordinator.push(.toastLab)
            } label: {
                Text("Toast Lab")
            }

            Button {
                coordinator.push(.doubleSheetLab)
            } label: {
                Text("Double Sheet Lab")
            }

            Button {
                coordinator.push(.hapticsLab)
            } label: {
                Text("Haptics Lab")
            }

            Button {
                coordinator.push(.cameraLab)
            } label: {
                Text("Camera Lab")
            }

            Button {
                coordinator.push(.wheelPickerLab)
            } label: {
                Text("Wheel Picker Toolbox")
            }

            Button {
                coordinator.push(.fixedSize)
            } label: {
                Text(".fixedSize() — cần học")
            }

            Button {
                coordinator.push(.flowRow)
            } label: {
                Text("FlowRow — chip tự xuống dòng")
            }

            Button {
                coordinator.push(.accordion)
            } label: {
                Text("Accordion Lab")
            }

            Button {
                coordinator.push(.kavsoftSwipeActionsScrollView)
            } label: {
                Text("Swipe Actions for ScrollView (Kavsoft)")
            }

            Button {
                coordinator.push(.calendarLab)
            } label: {
                Text("Calendar Lab")
            }

            Button {
                coordinator.push(.logger)
            } label: {
                Text("Logger")
            }
        }
        .navigationTitle("Appendix")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(.languagePicker)
                } label: {
                    Image(systemName: "globe")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppendixView()
            .environment(AppCoordinator())
    }
}
