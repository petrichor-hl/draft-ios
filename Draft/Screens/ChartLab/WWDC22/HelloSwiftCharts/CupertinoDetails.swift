//
//  CupertinoDetails.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Charts
import SwiftUI

let cupertinoData: [SalesSummary] = [
  /// Monday
  .init(weekday: date(2022, 5, 2), sales: 54),
  /// Tuesday
  .init(weekday: date(2022, 5, 3), sales: 42),
  /// Wednesday
  .init(weekday: date(2022, 5, 4), sales: 88),
  /// Thursday
  .init(weekday: date(2022, 5, 5), sales: 49),
  /// Friday
  .init(weekday: date(2022, 5, 6), sales: 42),
  /// Saturday
  .init(weekday: date(2022, 5, 7), sales: 125),
  /// Sunday
  .init(weekday: date(2022, 5, 8), sales: 67)
]

struct CupertinoDetails: View {
  var body: some View {
    Chart(cupertinoData) { element in
      BarMark(
        x: .value("Day", element.weekday, unit: .day),
        y: .value("Sales", element.sales)
      )
    }
    .frame(height: 240)
    .padding()
  }
}

#Preview {
  CupertinoDetails()
}
