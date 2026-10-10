import SwiftUI

struct ScrollableTabViewScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: Tab?
    @State private var tabProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "bell.badge")
                }
            }
            .font(.title2)
            .overlay {
                Text("Messages")
                    .font(.title3.bold())
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 15)
            
            customTabBar()
            
            GeometryReader { geometry in
                let size = geometry.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        sampleView(Color.purple)
                            .id(Tab.chats)
                            .containerRelativeFrame(.horizontal)
                        
                        sampleView(Color.red)
                            .id(Tab.calls)
                            .containerRelativeFrame(.horizontal)
                        
                        sampleView(Color.blue)
                            .id(Tab.settings)
                            .containerRelativeFrame(.horizontal)
                    }
                    .overlay {
                        GeometryReader { geometry in
                            let scrollOffset = -geometry.frame(in: .scrollView(axis: .horizontal)).minX
                            let progress = scrollOffset / (size.width * CGFloat(Tab.allCases.count - 1))
                            
                            Color.clear
                                .onChange(of: progress) { _, newProgress in
                                    tabProgress = max(0, min(newProgress, 1))
                                }
                        }
                    }
                }
                .scrollPosition(id: $selectedTab)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
            }
        }
        .background(Color.gray.opacity(0.1))
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @ViewBuilder
    func customTabBar() -> some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    HStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                        
                        Text(tab.rawValue)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    // Đặt tap gesture ở lớp dưới như này hoặc lớp trên đều được
                    // Lớp trên là sau dòng .padding(.vertical, 10) ở line 108
                    .contentShape(.capsule)
                    .onTapGesture { _ in
                        withAnimation(.snappy) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .foregroundStyle(.gray)
            
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    HStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                        
                        Text(tab.rawValue)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
            .symbolVariant(.fill)
            .mask { slidingCapsule() }
            
        }
        .background { slidingCapsule() }
        .padding(3)
        .background(Color.gray.opacity(0.1), in: .capsule)
        .padding(.horizontal, 15)
    }
    
    private func slidingCapsule() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let capsuleWidth = width / CGFloat(Tab.allCases.count)

            Capsule()
                .fill(Color.white)
                .frame(width: capsuleWidth)
                .offset(x: tabProgress * (width - capsuleWidth))
        }
    }
    
    @ViewBuilder
    func sampleView(_ color: Color) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                ForEach(1...10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.gradient)
                        .frame(height: 150)
                        .overlay {
                            VStack(alignment: .leading) {
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 80, height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.25))
                                        .frame(width: 60, height: 8)
                                }
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 40, height: 8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                        }
                }
            }
            .padding(15)
        }
        .scrollIndicators(.hidden)
    }
}
