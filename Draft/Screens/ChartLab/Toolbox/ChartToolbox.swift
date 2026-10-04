//
//  ChartToolbox.swift
//  Draft
//
//  Nhóm 4 — chart dựng lại từ app thật.
//

import SwiftUI

struct ChartToolbox: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    var body: some View {
        List {
            Button {
                coordinator.push(.chartAppleHealthSteps)
            } label: {
                ChartLabRow(
                    title: "Apple Health — Steps",
                    subtitle: "chartXSelection + chartOverlay, chạm hoặc nhấn giữ để chọn"
                )
            }
            
            Button {
                coordinator.push(.chartGarminHeartRate)
            } label: {
                ChartLabRow(
                    title: "Garmin Connect — Nhịp tim",
                    subtitle: "Đường liền đổi màu theo zone, trục Y cắt gốc, đứt đoạn khi không đeo"
                )
            }
            
            Button {
                coordinator.push(.chartStocks)
            } label: {
                ChartLabRow(
                    title: "Stocks — Giá cổ phiếu",
                    subtitle: "Area gradient, trục Y bên phải, miền khít dữ liệu"
                )
            }
            
            Button {
                coordinator.push(.chartViewPerMonth)
            } label: {
                ChartLabRow(
                    title: "Total views on YouTube channel by month",
                    subtitle: "Sean Allen"
                )
            }
        }
        .navigationTitle("Toolbox")
    }
}

#Preview {
    NavigationStack {
        ChartToolbox()
            .environment(AppCoordinator())
    }
}
