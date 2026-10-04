//
//  ViewPerMonthScreen.swift
//  Draft
//
//  Created by Trần Lê Hoàng Lâm on 4/10/26.
//
//  part 1: https://www.youtube.com/watch?v=4utsyqhnS4g
//  part 2: https://www.youtube.com/watch?v=uloAs9tQIcA

import SwiftUI
import Charts

private let viewMonths: [ViewMonth] = [
    .init(date: date(2025, 1, 1), viewCount: 55_000),
    .init(date: date(2025, 2, 1), viewCount: 89_000),
    .init(date: date(2025, 3, 1), viewCount: 64_000),
    .init(date: date(2025, 4, 1), viewCount: 79_000),
    .init(date: date(2025, 5, 1), viewCount: 130_000),
    .init(date: date(2025, 6, 1), viewCount: 90_000),
    .init(date: date(2025, 7, 1), viewCount: 105_000),
    .init(date: date(2025, 8, 1), viewCount: 118_000),
    .init(date: date(2025, 9, 1), viewCount: 96_000),
    .init(date: date(2025, 10, 1), viewCount: 142_000),
    .init(date: date(2025, 11, 1), viewCount: 125_000),
    .init(date: date(2025, 12, 1), viewCount: 160_000),
]

struct ViewPerMonthScreen: View {
    @State private var rawSelectedDate: Date?
    
    var selectedViewMonth: ViewMonth? {
        guard let rawSelectedDate else { return nil }
        return viewMonths.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.date, toGranularity: .month)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Group {
                Text("YouTube Views")
                
                Text("Total: \(viewMonths.reduce(0, { $0 + $1.viewCount }))")
                    .fontWeight(.semibold)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            .opacity(rawSelectedDate == nil ? 1 : 0)
            
            Chart {
                if let selectedViewMonth {
                    RuleMark(x: .value("Selected Month", selectedViewMonth.date, unit: .month))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .offset(yStart: -10)
                        .annotation(
                            position: .top,
                            overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                        ) {
                            VStack {
                                Text(selectedViewMonth.date, format: .dateTime.month(.wide))
                                    .bold()
                                
                                Text("\(selectedViewMonth.viewCount)")
                                    .font(.title3.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(width: 120)
                            .background(Color.pink.gradient, in: .rect(cornerRadius: 10))
                        }
                }
                
                ForEach(viewMonths) { viewMonth in
                    BarMark(
                        x: .value("Month", viewMonth.date, unit: .month),
                        y: .value("Views", viewMonth.viewCount),
                    )
                    .foregroundStyle(Color.pink.gradient)
                    .cornerRadius(10)
                    .opacity(rawSelectedDate == nil || viewMonth.date == selectedViewMonth?.date ? 1 : 0.3)
                }
            }
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                /*
                 Cách này chỉ hoạt động tốt nếu viewMonths array có đủ 12 tháng.
                 Thử comment một vài tháng trong viewMonths và sử dụng cách này sẽ thế UI bị lệch.
                 
                 Ngoài ra, nếu viewMonths có đủ 12 tháng thì cột thứ 12 sẽ bị mất label "D" (December)
                 Bỏ "centered: true" trong AxisValueLabel thì cột thứ 12 sẽ xuất hiện label "D" như các cột khác
                 Noted at: Sun 4 Oct 2026
                 
                 AxisMarks(values: viewMonths.map { $0.date }) {
                     AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                 }
                 */
                AxisMarks(values: .stride(by: .month, count: 1)) {
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                }
            }
            .frame(height: 240)
        }
        .padding()
    }
}

struct ViewMonth: Identifiable {
    let id = UUID()
    let date: Date
    let viewCount: Int
}
