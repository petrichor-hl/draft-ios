//
//  SegmentedControlScreen.swift
//  Draft
//
//  So sánh Picker segmented, matchedGeometryEffect và offset.
//  https://developer.apple.com/documentation/swiftui/segmentedpickerstyle
//

import SwiftUI

struct SegmentedControlScreen: View {
    @State private var systemSelection: Period = .day
    @State private var namespaceSelection: Period = .day
    @State private var customSelection: Period = .day
    @Namespace private var selectionNamespace

    var body: some View {
        List {
            Section("Picker mặc định") {
                Picker("Khoảng thời gian", selection: $systemSelection) {
                    ForEach(Period.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                LabeledContent("Đang chọn") {
                    Text(systemSelection.title)
                }
            }

            Section {
                namespaceControl

                LabeledContent("Đang chọn") {
                    Text(namespaceSelection.title)
                }
            } header: {
                Text("@Namespace + matchedGeometryEffect")
            } footer: {
                Text("Các capsule dùng chung id và namespace để animate giữa hai vị trí.")
            }

            Section {
                customControl

                LabeledContent("Đang chọn") {
                    Text(customSelection.title)
                }
            } header: {
                Text("Cách hiện tại — offset + animation")
            } footer: {
                Text("Một capsule làm nền chọn. offset và animation di chuyển nó giữa các mục.")
            }
        }
        .navigationTitle("SegmentedControl")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var namespaceControl: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases) { period in
                ZStack {
                    if namespaceSelection == period {
                        Capsule()
                            .fill(.white)
                            .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                    }

                    Button {
                        withAnimation(.snappy(duration: 0.25)) {
                            namespaceSelection = period
                        }
                    } label: {
                        Text(period.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(namespaceSelection == period ? Color.black : Color.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .contentShape(.capsule)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
            }
        }
        .padding(3)
        .background(.black.opacity(0.35), in: .capsule)
    }

    private var customControl: some View {
        GeometryReader { geometry in
            let segmentWidth = geometry.size.width / CGFloat(Period.allCases.count)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white)
                    .frame(width: segmentWidth, height: 38)
                    .offset(x: CGFloat(customSelection.rawValue) * segmentWidth)
                    .animation(.snappy(duration: 0.25), value: customSelection)
                    .allowsHitTesting(false)

                HStack(spacing: 0) {
                    ForEach(Period.allCases) { period in
                        Button {
                            customSelection = period
                        } label: {
                            Text(period.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(customSelection == period ? Color.black : Color.white.opacity(0.6))
                                .frame(width: segmentWidth, height: 38)
                                .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(customSelection == period ? .isSelected : [])
                    }
                }
            }
        }
        .frame(height: 38)
        .padding(3)
        .background(.black.opacity(0.35), in: .capsule)
    }

    private enum Period: Int, CaseIterable, Identifiable {
        case day, week, month

        var id: Self { self }

        var title: LocalizedStringKey {
            switch self {
            case .day: "Ngày"
            case .week: "Tuần"
            case .month: "Tháng"
            }
        }
    }
}

#Preview {
    NavigationStack {
        SegmentedControlScreen()
    }
}
