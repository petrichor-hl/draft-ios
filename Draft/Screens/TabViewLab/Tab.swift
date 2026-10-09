//
//  Tab.swift
//  Draft
//
//  Created by Trần Lê Hoàng Lâm on 9/10/26.
//

import Foundation

enum Tab: String, CaseIterable {
    case chats = "Chats"
    case calls = "Calls"
    case settings = "Settings"
    
    var systemImage: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right"
        case .calls: return "phone"
        case .settings: return "gear"
        }
    }
}
