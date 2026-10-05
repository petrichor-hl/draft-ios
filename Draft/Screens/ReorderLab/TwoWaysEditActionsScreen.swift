//
//  TwoWaysEditActionsScreen.swift
//  Draft
//
//  Reorder a List (2 Ways) — cách 1: `editActions:`.
//  Code theo video: https://www.youtube.com/watch?v=VNRdRlHsr2k
//

import SwiftUI

struct TwoWaysEditActionsScreen: View {

    @State private var episodes: [Episode] = [
        .init(title: "Pink Episode", color: .pink, listOrder: 0),
        .init(title: "Teal Episode", color: .teal, listOrder: 1),
        .init(title: "Idogo Episode", color: .indigo, listOrder: 2),
        .init(title: "Orange Episode", color: .orange, listOrder: 3),
        .init(title: "Blue Episode", color: .blue, listOrder: 4),
        .init(title: "Green Episode", color: .green, listOrder: 5),
        .init(title: "Purple Episode", color: .purple, listOrder: 6),
        .init(title: "Yellow Episode", color: .yellow, listOrder: 7)
    ]

    var body: some View {
        List($episodes, editActions: .move) { episode in
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(episode.color.wrappedValue)
                    .overlay {
                        Text("\(episode.listOrder.wrappedValue)")
                    }

                VStack(alignment: .leading) {
                    Text("Episode Title")
                        .font(.headline)

                    Text("Here is the short description for the latest episode.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("editActions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Episode: Identifiable {
    let id = UUID()
    var title: String
    var color: Color
    var listOrder: Int

    init(title: String, color: Color, listOrder: Int) {
        self.title = title
        self.color = color
        self.listOrder = listOrder
    }
}
