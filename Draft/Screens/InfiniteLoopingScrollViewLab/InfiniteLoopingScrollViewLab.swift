import SwiftUI

struct InfiniteLoopingScrollViewLab: View {
    @State private var items: [Item] = [
        .init(color: .red),
        .init(color: .blue),
        .init(color: .green),
        .init(color: .yellow),
        .init(color: .black),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("1. Infinite Looping ScrollView")
                    .padding(.leading, 15)
                LoopingScrollView(
                    width: 150,
                    spacing: 10,
                    items: items,
                ) { item in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(item.color.gradient)
                }
                .frame(height: 150)
                .contentMargins(.horizontal, 15, for: .scrollContent)
                .scrollIndicators(.hidden)

                Divider()
                    .padding(.top, 14)
                    .padding(.top, 30)

                Text("2. Infinite Looping ScrollView - Carousel")
                    .padding(.leading, 15)
                GeometryReader { geometry in
                    let size = geometry.size

                    LoopingScrollView(
                        width: size.width,
                        items: items,
                    ) { item in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(item.color.gradient)
                            .padding(.horizontal, 15)
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                }
                .frame(height: 220)
            }
            .padding(.vertical, 15)
        }
        .navigationTitle("Infinite Looping ScrollView Lab")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Item: Identifiable {
    var id = UUID()
    var color: Color
}
