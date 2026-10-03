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
                coordinator.push(.scrollViewLab)
            } label: {
                Text("ScrollView Lab")
            }

            Button {
                coordinator.push(.bottomSheetLab)
            } label: {
                Text("Bottom Sheet Lab")
            }

            Button {
                coordinator.push(.keyboardLab)
            } label: {
                Text("Keyboard Lab")
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
                coordinator.push(.segmentedControl)
            } label: {
                Text("SegmentedControl")
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
                coordinator.push(.calendarLab)
            } label: {
                Text("Calendar Lab")
            }

            Button {
                coordinator.push(.menuLab)
            } label: {
                Text("Menu Lab")
            }

            Button {
                coordinator.push(.chartLab)
            } label: {
                Text("Chart Lab")
            }

            Button {
                coordinator.push(.sliderToolbox)
            } label: {
                Text("Slider Toolbox")
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
