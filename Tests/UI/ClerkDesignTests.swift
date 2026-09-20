//
//  ClerkDesignTests.swift
//  Clerk
//

#if os(iOS) || os(macOS)

@testable import ClerkKitUI
import SwiftUI
import Testing

struct ClerkDesignTests {
  /// The new tokens must leave upstream rendering untouched, so every one of them
  /// defaults to the behavior the views had before they existed.
  @Test
  func defaultsLeaveEveryNewTokenInert() {
    let design = ClerkTheme.Design()

    #expect(design.borderRadius == 6)
    #expect(design.buttonRadius == nil)
    #expect(design.showsContinueIcon)
    #expect(design.titleWeight == nil)
    #expect(!design.linkUnderline)
    #expect(design.buttonFontWeight == nil)
  }

  @Test
  func defaultTokensMatchAFreshlyInitializedDesign() {
    let design = ClerkTheme.Design.default

    #expect(design.borderRadius == 6)
    #expect(design.buttonRadius == nil)
    #expect(design.showsContinueIcon)
    #expect(design.titleWeight == nil)
    #expect(!design.linkUnderline)
    #expect(design.buttonFontWeight == nil)
  }

  /// A host asking for a pill call to action must not round its text fields with it.
  @Test
  func buttonRadiusLeavesBorderRadiusAlone() {
    let design = ClerkTheme.Design(buttonRadius: 24)

    #expect(design.buttonRadius == 24)
    #expect(design.borderRadius == 6)
  }

  @Test
  func everyTokenIsSettableThroughTheInitializer() {
    let design = ClerkTheme.Design(
      borderRadius: 12,
      buttonRadius: 24,
      showsContinueIcon: false,
      titleWeight: .medium,
      linkUnderline: true,
      buttonFontWeight: .medium
    )

    #expect(design.borderRadius == 12)
    #expect(design.buttonRadius == 24)
    #expect(!design.showsContinueIcon)
    #expect(design.titleWeight == .medium)
    #expect(design.linkUnderline)
    #expect(design.buttonFontWeight == .medium)
  }
}

#endif
