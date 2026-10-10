import SwiftUI

struct CarouselToolbox: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(.animatedCarouselSlider)
            } label: {
                Text("SwiftUI Animated Carousel Slider With Paging Control")
            }

            Button {
                coordinator.push(.animatedPagingIndicators)
            } label: {
                Text("SwiftUI Animated Paging Indicators")
            }

            Button {
                coordinator.push(.parallaxCarousel)
            } label: {
                Text("Parallax Carousel Scroll")
            }

            Button {
                coordinator.push(.coverFlow)
            } label: {
                Text("SwiftUI CoverFlow - iOS 17")
            }
        }
        .navigationTitle("Carousel Toolbox")
    }
}

#Preview {
    NavigationStack {
        CarouselToolbox()
            .environment(AppCoordinator())
    }
}
