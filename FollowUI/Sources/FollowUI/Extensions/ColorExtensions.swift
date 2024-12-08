//
//  ColorExtensions.swift
//  FollowUI
//
//  Created by Ziyuan Zhao on 2024/12/7.
//

import SwiftUI

#if canImport(UIKit)
// MARK: Color + UIKit
extension Color {
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
}
#elseif canImport(AppKit)
// MARK: Color + AppKit
extension Color {
    static let label = Color(nsColor: .labelColor)
    
    static let secondaryLabel = Color(nsColor: .secondaryLabelColor)
    
    // TODO: Find a proper color
    static let systemGroupedBackground = Color(nsColor: .underPageBackgroundColor)
}
#endif
