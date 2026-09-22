//
//  ContentMarginsScreen.swift
//  Draft
//

import SwiftUI

/// A small interactive playground to explore `.contentMargins(_:_:for:)`.
/// Drag the slider to change the inset value, pick which edges it applies
/// to, and switch `placement` to compare how margins affect the scrollable
/// content versus the scroll indicators.
struct ContentMarginsScreen: View {
    @State private var margin: CGFloat = 0
    @State private var edgesOption: MarginEdgesOption = .all
    @State private var placementOption: MarginPlacementOption = .scrollContent

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<20) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.gradient)
                            .frame(height: 60)
                            .overlay(
                                Text("Row \(index)")
                                    .foregroundStyle(.white)
                            )
                    }
                }
                .padding(.horizontal)
            }
            .contentMargins(edgesOption.edges, margin, for: placementOption.placement)
            .background(Color.yellow.opacity(0.25))

            Divider()

            controls
                .padding()
        }
        .navigationTitle("contentMargins Playground")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            edgesPicker
            placementPicker

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Margin")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(margin)) pt")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Slider(value: $margin, in: 0...200, step: 10)
            }

            Button("Reset to 0") {
                margin = 0
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }

    private var edgesPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Edges")
                .font(.subheadline.weight(.medium))
            Picker("Edges", selection: $edgesOption) {
                ForEach(MarginEdgesOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var placementPicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Placement")
                .font(.subheadline.weight(.medium))
            Picker("Placement", selection: $placementOption) {
                ForEach(MarginPlacementOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

/// Which edges the margin is applied to — mirrors the `Edge.Set` values
/// accepted by `.contentMargins(_:_:for:)`.
private enum MarginEdgesOption: String, CaseIterable, Identifiable {
    case all
    case top
    case bottom
    case horizontal
    case vertical

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .top: "Top"
        case .bottom: "Bottom"
        case .horizontal: "Sides"
        case .vertical: "Vert."
        }
    }

    var edges: Edge.Set {
        switch self {
        case .all: .all
        case .top: .top
        case .bottom: .bottom
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }
}

/// Wraps `ContentMarginPlacement` in a `Picker`-friendly enum, since
/// `ContentMarginPlacement` itself is a set of static members rather than
/// a `CaseIterable` enum.
private enum MarginPlacementOption: String, CaseIterable, Identifiable {
    case automatic
    case scrollContent
    case scrollIndicators

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "Auto"
        case .scrollContent: "Content"
        case .scrollIndicators: "Indicators"
        }
    }

    var placement: ContentMarginPlacement {
        switch self {
        case .automatic: .automatic
        case .scrollContent: .scrollContent
        case .scrollIndicators: .scrollIndicators
        }
    }
}

#Preview {
    NavigationStack {
        ContentMarginsScreen()
    }
}
