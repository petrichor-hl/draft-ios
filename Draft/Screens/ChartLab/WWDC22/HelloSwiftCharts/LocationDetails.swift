//
//  LocationDetails.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Charts
import SwiftUI

let seriesData: [Series] = [
  .init(city: "Cupertino", sales: cupertinoData),
  .init(city: "San Francisco", sales: sfData)
]

struct LocationDetails: View {
  var body: some View {
    Chart(seriesData) { series in
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
    .frame(height: 300)
    .padding()
  }
}
