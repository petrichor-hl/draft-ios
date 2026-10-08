import SwiftUI

extension Color {
    /// Semantic colors resolve their Any/Dark asset variants in the current environment.
    enum Semantic {
        enum Action {
            static let primaryBackground = Color("SemanticColor/Action/PrimaryBackground")
            static let primaryForeground = Color("SemanticColor/Action/PrimaryForeground")
        }

        enum Background {
            static let app = Color("SemanticColor/Background/App")
            static let surface = Color("SemanticColor/Background/Surface")
        }

        enum Text {
            static let primary = Color("SemanticColor/Text/Primary")
            static let secondary = Color("SemanticColor/Text/Secondary")
        }
    }
}
