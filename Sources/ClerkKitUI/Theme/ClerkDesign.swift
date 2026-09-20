//
//  ClerkDesign.swift
//  Clerk
//

#if os(iOS) || os(macOS)

import Foundation
import SwiftUI

extension ClerkTheme {
  /// Design tokens that control layout and shape across ClerkKitUI views.
  public struct Design {
    /// The default corner radius applied to ClerkKitUI surfaces.
    public var borderRadius: CGFloat

    /// The corner radius applied to buttons only. When `nil`, buttons use ``borderRadius``.
    ///
    /// Set this to draw a pill-shaped call to action while text fields keep ``borderRadius``.
    public var buttonRadius: CGFloat?

    /// Whether the "Continue" button label shows its trailing icon.
    public var showsContinueIcon: Bool

    /// The weight applied to screen titles. When `nil`, titles stay bold.
    public var titleWeight: Font.Weight?

    /// Whether link-style text buttons are underlined.
    public var linkUnderline: Bool

    /// The weight applied to button labels. When `nil`, labels keep the weight of their font.
    public var buttonFontWeight: Font.Weight?

    /// Creates design tokens used by ClerkKitUI views.
    public init(
      borderRadius: CGFloat = Self.default.borderRadius,
      buttonRadius: CGFloat? = nil,
      showsContinueIcon: Bool = true,
      titleWeight: Font.Weight? = nil,
      linkUnderline: Bool = false,
      buttonFontWeight: Font.Weight? = nil
    ) {
      self.borderRadius = borderRadius
      self.buttonRadius = buttonRadius
      self.showsContinueIcon = showsContinueIcon
      self.titleWeight = titleWeight
      self.linkUnderline = linkUnderline
      self.buttonFontWeight = buttonFontWeight
    }
  }
}

extension ClerkTheme.Design {
  /// The default set of design tokens used by ClerkKitUI.
  public nonisolated static var `default`: Self {
    .init(
      borderRadius: 6.0
    )
  }
}

#endif
