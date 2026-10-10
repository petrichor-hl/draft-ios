//
//  LoopingScrollView.swift
//  Draft
//
//  Created by Trần Lê Hoàng Lâm on 9/10/26.
//

import SwiftUI

struct LoopingScrollView<Content: View, Collecntion: RandomAccessCollection>: View where Collecntion.Element: Identifiable {
    var width: CGFloat
    var spacing: CGFloat = 0

    var items: Collecntion
    @ViewBuilder var content: (Collecntion.Element) -> Content

    init(
        width: CGFloat,
        spacing: CGFloat = 0,
        items: Collecntion,
        @ViewBuilder content: @escaping (Collecntion.Element) -> Content
    ) {
        precondition(width > 0, "LoopingScrollView width must be greater than zero.")
        self.width = width
        self.spacing = spacing
        self.items = items
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let repeatingCount = Int((size.width / (width + spacing)).rounded(.down)) + 1

            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: width)
                    }

                    ForEach(0..<repeatingCount, id: \.self) { index in
                        let item = Array(items)[index % items.count]
                        content(item)
                            .frame(width: width)
                    }
                }
                .background {
                    ScrollViewHelper(
                        width: width,
                        spacing: spacing,
                        itemCount: items.count,
                        repeatingCount: repeatingCount
                    )
                }
            }
        }
    }
}

fileprivate struct ScrollViewHelper: UIViewRepresentable {
    var width: CGFloat
    var spacing: CGFloat
    var itemCount: Int
    var repeatingCount: Int

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            width: width,
            spacing: spacing,
            itemCount: itemCount,
            repeatingCount: repeatingCount
        )
    }

    func makeUIView(context: Context) -> some UIView {
        return .init()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView,
                context.coordinator.isAdded == false {
                scrollView.delegate = context.coordinator
                context.coordinator.isAdded = true
            }
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var width: CGFloat
        var spacing: CGFloat = 0
        var itemCount: Int
        var repeatingCount: Int

        init(width: CGFloat, spacing: CGFloat, itemCount: Int, repeatingCount: Int) {
            self.width = width
            self.spacing = spacing
            self.itemCount = itemCount
            self.repeatingCount = repeatingCount
        }

        /// Tell us wether the delegate is added or not
        var isAdded: Bool = false

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard itemCount > 0 else { return }

            let minX = scrollView.contentOffset.x
            let mainContentSize = CGFloat(itemCount) * width
            let spacingSize = CGFloat(itemCount) * spacing

            if (minX + scrollView.contentInset.left) > (mainContentSize + spacingSize) {
                scrollView.contentOffset.x -= mainContentSize + spacingSize
            }

            if (minX + scrollView.contentInset.left) < 0 {
                scrollView.contentOffset.x += mainContentSize + spacingSize
            }
        }
    }
}
