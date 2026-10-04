//
//  ChartLab.swift
//  Draft
//
//  Menu các nhóm thí nghiệm về Swift Charts: cơ chế nền, từng loại chart,
//  tương tác, và các chart dựng lại từ app thật. Phần dựng theo video để
//  riêng, khỏi lẫn vào lộ trình.
//

import SwiftUI

struct ChartLab: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    var body: some View {
        List {
            Section {
                Button {
                    coordinator.push(.chartBasics)
                } label: {
                    ChartLabRow(title: "1. Basics",
                                subtitle: "Chart, Mark, PlottableValue — kiểu dữ liệu quyết định loại trục")
                }
                
                Button {
                    coordinator.push(.chartTypes)
                } label: {
                    ChartLabRow(title: "2. Các loại chart",
                                subtitle: "Column, Bar, Line, Area, Point, Pie, Range, Heatmap")
                }
                
                Button {
                    coordinator.push(.chartInteraction)
                } label: {
                    ChartLabRow(title: "3. Tương tác",
                                subtitle: "Chạm chọn điểm, cuộn ngang, snap từng trang")
                }
                
                Button {
                    coordinator.push(.chartToolbox)
                } label: {
                    ChartLabRow(title: "4. Toolbox",
                                subtitle: "Chart dựng lại từ app thật: Apple Health, Garmin Connect")
                }
            }
            
            Divider()
            
            Section("WWDC22") {
                Button {
                    coordinator.push(.chartHelloSwiftCharts)
                } label: {
                    ChartLabRow(title: "Hello Swift Charts",
                                subtitle: "Apple")
                }
                
                Button {
                    coordinator.push(.chartRaiseTheBar)
                } label: {
                    ChartLabRow(title: "Swift Charts: Raise the bar",
                                subtitle: "Apple")
                }
            }
            
            Section("WWDC23") {
                Button {
                    coordinator.push(.chartExplorePieChartsAndInteractivity)
                } label: {
                    ChartLabRow(title: "Explore pie charts and interactivity in Swift Charts",
                                subtitle: "Apple")
                }
            }
        }
        .navigationTitle("Chart Lab")
    }
}

#Preview {
    NavigationStack {
        ChartLab()
            .environment(AppCoordinator())
    }
}
