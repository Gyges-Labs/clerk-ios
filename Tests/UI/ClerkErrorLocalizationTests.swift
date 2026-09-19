//
//  ClerkErrorLocalizationTests.swift
//  Clerk
//

#if os(iOS) || os(macOS)

@testable import ClerkKit
@testable import ClerkKitUI
import Foundation
import Testing

struct ClerkErrorLocalizationTests {
  private let japanese = Locale(identifier: "ja")
  private let traditionalChinese = Locale(identifier: "zh-Hant")
  private let english = Locale(identifier: "en")

  /// Decodes an error body the way the networking layer does, so `long_message` and
  /// `meta.param_name` are exercised through the real decoding contract rather than hand-built.
  private func apiError(_ body: String) throws -> ClerkAPIError {
    try JSONDecoder.clerkDecoder.decode(ClerkAPIError.self, from: Data(body.utf8))
  }

  // MARK: - Fixtures

  private let passwordIncorrect = """
    {
      "code": "form_password_incorrect",
      "message": "Incorrect password",
      "long_message": "Password is incorrect. Try again, or use another method.",
      "meta": { "param_name": "password" }
    }
    """

  private let passwordPwnedOnSignIn = """
    {
      "code": "form_password_pwned",
      "message": "Password has been found in an online data breach",
      "long_message": "This password has been found as part of a breach and can not be used, please reset your password.",
      "meta": { "param_name": "sign_in" }
    }
    """

  private let unknownCode = """
    {
      "code": "a_code_the_catalog_does_not_know",
      "message": "Short server copy",
      "long_message": "Longer server copy that explains what went wrong.",
      "meta": {}
    }
    """

  private let unknownCodeWithoutLongMessage = """
    {
      "code": "a_code_the_catalog_does_not_know",
      "message": "Short server copy"
    }
    """

  // MARK: - Decoding contract

  @Test
  func decodingExposesTheFieldsTheLookupReadsOn() throws {
    let error = try apiError(passwordPwnedOnSignIn)

    #expect(error.code == "form_password_pwned")
    #expect(error.longMessage == "This password has been found as part of a breach and can not be used, please reset your password.")
    #expect(error.message == "Password has been found in an online data breach")
    #expect(error.meta?["param_name"]?.stringValue == "sign_in")
  }

  // MARK: - Translated codes

  @Test
  func knownCodeUsesTheJapaneseTranslation() throws {
    let error = try apiError(passwordIncorrect)

    #expect(
      ClerkErrorLocalization.message(for: error, locale: japanese)
        == "入力されたパスワードが正しくありません。もう一度お試しください。"
    )
  }

  @Test
  func knownCodeUsesTheTraditionalChineseTranslation() throws {
    let error = try apiError(passwordIncorrect)

    #expect(
      ClerkErrorLocalization.message(for: error, locale: traditionalChinese)
        == "密碼不正確。請再試一次，或使用其他方式。"
    )
  }

  @Test
  func parameterScopedKeyWinsOverTheBareCode() throws {
    let error = try apiError(passwordPwnedOnSignIn)

    // Both `clerk_error_form_password_pwned` and `clerk_error_form_password_pwned__sign_in` are in
    // the catalog; the parameter-scoped entry is the one that tells the user to reset.
    #expect(
      ClerkErrorLocalization.message(for: error, locale: japanese)
        == "このパスワードは侵害の一部として見つかったため使用できません。パスワードをリセットしてください。"
    )

    var withoutParameter = error
    withoutParameter.meta = nil

    #expect(
      ClerkErrorLocalization.message(for: withoutParameter, locale: japanese)
        == "このパスワードは侵害の一部として見つかったため使用できません。別のパスワードを試してください。"
    )
  }

  // MARK: - Server copy fallbacks

  @Test
  func englishKeepsTheServerCopy() throws {
    let error = try apiError(passwordPwnedOnSignIn)

    // The catalog deliberately ships no English entries, so English readers see the API's own
    // wording, which stays current without an SDK release.
    #expect(
      ClerkErrorLocalization.message(for: error, locale: english)
        == "This password has been found as part of a breach and can not be used, please reset your password."
    )
  }

  @Test
  func unknownCodeFallsBackToTheServerLongMessage() throws {
    let error = try apiError(unknownCode)

    for locale in [japanese, traditionalChinese, english] {
      #expect(
        ClerkErrorLocalization.message(for: error, locale: locale)
          == "Longer server copy that explains what went wrong."
      )
    }
  }

  @Test
  func unknownCodeWithoutLongMessageFallsBackToTheServerMessage() throws {
    let error = try apiError(unknownCodeWithoutLongMessage)

    #expect(error.longMessage == nil)
    #expect(ClerkErrorLocalization.message(for: error, locale: japanese) == "Short server copy")
  }

  // MARK: - Non-API errors

  @Test
  func clerkClientErrorKeepsItsOwnDescription() {
    // The catalog carries `clerk_error_passkey_not_supported` for the same sentence, but a
    // client-side error is not an API error and must keep whatever description it was built with.
    let error = ClerkClientError(message: "Passkeys are not supported on this device.")

    #expect(
      ClerkErrorLocalization.message(for: error, locale: japanese)
        == "Passkeys are not supported on this device."
    )
    #expect(ClerkErrorLocalization.message(for: error, locale: japanese) == error.localizedDescription)
  }

  @Test
  func foundationErrorKeepsItsOwnDescription() {
    let error = NSError(
      domain: "ClerkErrorLocalizationTests",
      code: 42,
      userInfo: [NSLocalizedDescriptionKey: "Something unrelated went wrong."]
    )

    #expect(
      ClerkErrorLocalization.message(for: error, locale: japanese)
        == "Something unrelated went wrong."
    )
  }

  @Test
  func defaultsToTheBundlesPreferredLocalization() throws {
    // `Locale.current` follows the device's first language even when the bundle does not ship it
    // and a later preference is. The default must be the localization the bundle resolves to, so
    // the error copy speaks the same language as the rest of the bundle's views.
    let error = try apiError(passwordIncorrect)
    let bundleLocale = ClerkErrorLocalization.preferredLocale()
    #expect(
      ClerkErrorLocalization.message(for: error)
        == ClerkErrorLocalization.message(for: error, locale: bundleLocale)
    )
  }
}

#endif
