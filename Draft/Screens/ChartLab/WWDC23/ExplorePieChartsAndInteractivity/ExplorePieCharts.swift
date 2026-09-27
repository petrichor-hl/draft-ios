//
//  ExplorePieCharts.swift
//  Draft
//
//  Created by Lam Tran  on 27/9/26.
//

import Charts
import SwiftUI

struct ExplorePieCharts: View {
  @State private var selectedAngle: Int?

  private let data: [PancakeSale] = [
    .init(name: "Cachapa", sales: 56),
    .init(name: "Injera", sales: 39),
    .init(name: "Crêpe", sales: 42),
    .init(name: "Jian Bing", sales: 28),
    .init(name: "Dosa", sales: 34),
    .init(name: "American", sales: 61),
  ]

  private var mostSold: String {
    data.max(by: { $0.sales < $1.sales })?.name ?? ""
  }

  private var selectedSale: PancakeSale? {
    guard let selectedAngle else { return nil }

    var cumulativeSales = 0
    for element in data {
      cumulativeSales += element.sales
      if selectedAngle < cumulativeSales {
        return element
      }
    }
    return nil
  }

  var body: some View {
    VStack {
      Chart(data, id: \.name) { element in
        SectorMark(
          angle: .value("Sales", element.sales),
          innerRadius: .ratio(0.618),
          angularInset: 1.5
        )
        .cornerRadius(5)
        .foregroundStyle(by: .value("Name", element.name))
        .opacity(selectedSale == nil || element.name == selectedSale?.name ? 1 : 0.3)
      }
      .chartAngleSelection(value: $selectedAngle)
      .chartLegend(
        position: .bottom,
        alignment: .center,
        spacing: 24
      )
      .chartBackground { chartProxy in
        GeometryReader { geometry in
          if let plotFrame = chartProxy.plotFrame {
            let frame = geometry[plotFrame]
            VStack {
              Text(selectedSale?.name ?? "Most Sold Style")
                .font(.callout)
                .foregroundStyle(.secondary)
              Text(selectedSale.map { "\($0.sales.formatted()) sold" } ?? mostSold)
                .font(.title2.bold())
                .foregroundColor(.primary)
            }
            .position(x: frame.midX, y: frame.midY)
          }
        }
      }
      .frame(height: 300)

      Spacer()
    }
    .padding()
  }
}

private struct PancakeSale {
  let name: String
  let sales: Int
}

#Preview {
  ExplorePieCharts()
}
