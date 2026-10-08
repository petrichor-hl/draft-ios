//
//  InteractivityInSwiftCharts.swift
//  Draft
//
//  Created by Lam Tran  on 27/9/26.
//

import Charts
import SwiftUI

struct Interactivity: View {
  @State var rawSelectedDate: Date?
  private let weekEnd = date(2022, 5, 9)

  private var selectedDate: Date? {
    guard let rawSelectedDate else { return nil }
    return seriesData
      .lazy
      .flatMap(\.sales)
      .first { Calendar.current.isDate($0.weekday, inSameDayAs: rawSelectedDate) }?
      .weekday
  }

  private var mostSalesDescription: String {
    let highest = seriesData
      .flatMap { series in
        series.sales.map { (city: series.city, day: $0.weekday, sales: $0.sales) }
      }
      .max(by: { $0.sales < $1.sales })
    guard let highest else { return "" }

    let weekday = highest.day.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "en_US")))
    return "\(weekday)s in \(highest.city)"
  }

  private func selectDate(at x: CGFloat, using proxy: ChartProxy) {
    guard x >= 0, x <= proxy.plotSize.width,
          let day = proxy.value(atX: x, as: Date.self),
          seriesData.contains(where: { series in
            series.sales.contains {
              Calendar.current.isDate($0.weekday, inSameDayAs: day)
            }
          })
    else {
      rawSelectedDate = nil
      return
    }
    proxy.selectXValue(at: x)
  }

  private func valueSelectionPopover(for day: Date) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Average on \(day.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "en_US"))))s")
        .font(.callout)
        .foregroundStyle(.secondary)

      HStack(alignment: .top, spacing: 16) {
        ForEach(seriesData) { series in
          if let point = series.sales.first(where: {
            Calendar.current.isDate($0.weekday, inSameDayAs: day)
          }) {
            let color: Color = series.city == "Cupertino" ? .blue : .green
            VStack(alignment: .leading, spacing: 2) {
              HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(point.sales.formatted())
                  .font(.title2.bold())
                  .foregroundStyle(color)
                Text("sales")
                  .font(.callout)
                  .foregroundStyle(.secondary)
              }
              HStack(spacing: 4) {
                Image(systemName: series.city == "Cupertino" ? "circle" : "square")
                  .foregroundStyle(color)
                Text(series.city)
                  .foregroundStyle(.secondary)
              }
              .font(.caption)
            }
          }
        }
      }
    }
    .padding(10)
    .background(
      Color.black.opacity(0.08),
      in: .rect(cornerRadius: 8)
    )
    .fixedSize()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(alignment: .leading, spacing: 2) {
        Text("Day + Location With Most Sales")
          .font(.callout)
          .foregroundStyle(.secondary)
        Text(mostSalesDescription)
          .font(.title2.bold())
      }
      .padding(.bottom, 8)
      .opacity(selectedDate == nil ? 1 : 0)

      Chart {
        if let selectedDate {
          RuleMark(
            x: .value("Selected", selectedDate, unit: .day)
          )
          .foregroundStyle(Color.gray.opacity(0.2))
          .offset(yStart: -10)
          .annotation(
            position: .top,
            spacing: 0,
            overflowResolution: .init(
              x: .fit(to: .chart),
              y: .disabled
            )
          ) {
            valueSelectionPopover(for: selectedDate)
          }
        }

        ForEach(seriesData) { series in
          ForEach(series.sales) { element in
            LineMark(
              x: .value("Day", element.weekday, unit: .day),
              y: .value("Sales", element.sales)
            )
            .foregroundStyle(by: .value("City", series.city))
            .symbol(by: .value("City", series.city))
            .interpolationMethod(.catmullRom)
          }
        }
      }
      .chartXSelection(value: $rawSelectedDate)
      .chartGesture { proxy in
        DragGesture(minimumDistance: 0)
          .onChanged { selectDate(at: $0.location.x, using: proxy) }
          .onEnded { selectDate(at: $0.location.x, using: proxy) }
      }
      .chartForegroundStyleScale([
        "Cupertino": Color.blue,
        "San Francisco": Color.green
      ])
      .chartXScale(domain: date(2022, 5, 2)...weekEnd)
      .chartXAxis {
        AxisMarks(values: cupertinoData.map(\.weekday) + [weekEnd]) { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(centered: true) {
            if let day = value.as(Date.self), day < weekEnd {
              Text(day.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US"))))
            }
          }
        }
      }
      .chartLegend(
        position: .top,
        alignment: .leading,
        spacing: 24
      ) {
        HStack(spacing: 16) {
          ForEach(seriesData) { series in
            HStack(spacing: 6) {
              Image(systemName: series.city == "Cupertino" ? "circle.fill" : "square.fill")
                .foregroundStyle(series.city == "Cupertino" ? Color.blue : Color.green)
              Text(series.city)
            }
          }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .opacity(selectedDate == nil ? 1 : 0)
      }
      .frame(height: 300)

      Spacer()
    }
    .padding()
  }
}
