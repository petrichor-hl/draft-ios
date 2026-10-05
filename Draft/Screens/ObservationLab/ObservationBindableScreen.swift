//
//  ObservationBindableScreen.swift
//  Draft
//
//  Apple Documentation: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app

import SwiftUI
import Observation

struct ObservationBindableScreen: View {
    @State private var book = Book()
    @State private var renderCounter = RenderCounter()

    var body: some View {
        let renderCount = renderCounter.increment()
        return VStack(spacing: 0) {
            Text("ObservationBindableScreen.body: \(renderCount) lần")
                .font(.title3)
                .foregroundStyle(.secondary)

            BookEditView(book: book)
        }
        .navigationTitle("@Bindable")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BookEditView: View {
    @Bindable var book: Book
    @State private var renderCounter = RenderCounter()

    var body: some View {
        let renderCount = renderCounter.increment()
        return VStack {
            Text("BookEditView.body: \(renderCount) lần")
                .font(.title3)
                .foregroundStyle(.secondary)
                .padding(.bottom)

            HStack {
                Text("Title")
                TextField("Title", text: $book.title)
                    .textFieldStyle(.roundedBorder)
            }

            Toggle(isOn: $book.isAvailable) {
                Text("Book is available")
            }
        }
        .padding()
    }
}

@Observable
private final class Book {
    var title = "Sample Book Title"
    var isAvailable = true
}

private final class RenderCounter {
    private var count = 0

    func increment() -> Int {
        count += 1
        return count
    }
}
