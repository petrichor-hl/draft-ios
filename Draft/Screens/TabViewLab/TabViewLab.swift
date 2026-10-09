import SwiftUI

struct TabViewLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.scrollableTabView)
            } label: {
                Text("Building Scrollable Tab View With New iOS 17 APIs")
            }
        }
        .navigationTitle("TabView Lab")
    }
}

#Preview {
    NavigationStack {
        TabViewLab()
            .environment(AppCoordinator())
    }
}
