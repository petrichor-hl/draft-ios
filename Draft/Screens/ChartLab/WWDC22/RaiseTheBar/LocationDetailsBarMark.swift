//
//  LocationDetails.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Charts
import SwiftUI

struct LocationDetailsBarMark: View {
  var body: some View {
    Chart(seriesData) { series in
      ForEach(series.sales) { element in
        BarMark(
          x: .value("Day", element.weekday, unit: .day),
          y: .value("Sales", element.sales)
        )
      }
      .foregroundStyle(by: .value("City", series.city))
      // .position(by: .value("City", series.city))
    }
    .frame(height: 300)
    .padding()
  }
}
