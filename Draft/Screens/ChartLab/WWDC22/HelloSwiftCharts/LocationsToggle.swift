//
//  LocationsToggle.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Charts
import SwiftUI

let sfData: [SalesSummary] = [
  /// Monday
  .init(weekday: date(2022, 5, 2), sales: 81),
  /// Tuesday
  .init(weekday: date(2022, 5, 3), sales: 90),
  /// Wednesday
  .init(weekday: date(2022, 5, 4), sales: 52),
  /// Thursday
  .init(weekday: date(2022, 5, 5), sales: 72),
  /// Friday
  .init(weekday: date(2022, 5, 6), sales: 84),
  /// Saturday
  .init(weekday: date(2022, 5, 7), sales: 84),
  /// Sunday
  .init(weekday: date(2022, 5, 8), sales: 137)
]

struct LocationsToggle: View {
  @State var city: City = .cupertino
  
  var data: [SalesSummary] {
    switch city {
    case .cupertino:
      return cupertinoData
    case .sanFrancisco:
      return sfData
    }
  }
  
  var body: some View {
    VStack {
      Picker("City", selection: $city.animation(.easeInOut)) {
        Text("Cupertino").tag(City.cupertino)
        Text("San Francisco").tag(City.sanFrancisco)
      }
      .pickerStyle(.segmented)
      
      Chart(data) { element in
        BarMark(
          x: .value("Day", element.weekday, unit: .day),
          y: .value("Sales", element.sales)
        )
      }
      .frame(height: 240)
    }
    .padding()
  }
}
