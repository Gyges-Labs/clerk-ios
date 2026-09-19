//
//  ClerkErrorLocalization.swift
//  Clerk
//

import ClerkKit
import Foundation

/// Resolves the copy shown to a user for an error surfaced by a Clerk component.
///
/// The Clerk API returns error copy in English only, so a localized app would otherwise show an
/// English sentence in the middle of a translated screen. When the string catalog carries an entry
/// for the error's code, that translation is used; otherwise the server copy is shown unchanged so
/// that codes the catalog does not know about stay readable instead of blank or generic.
///
/// The lookup order mirrors `translateError` in `clerk-js`:
/// 1. `clerk_error_<code>__<param_name>` — the code scoped to the parameter it was reported for.
/// 2. `clerk_error_<code>` — the code on its own.
/// 3. The server's `longMessage`, then its `message`.
enum ClerkErrorLocalization {
  /// Localized copy for a Clerk API error when the catalog has an entry for its code; otherwise the server text.
  ///
  /// - Parameters:
  ///   - error: The error to describe. Errors that are not ``ClerkAPIError`` are described by
  ///     `localizedDescription`, which is already localized by whoever created them.
  ///   - bundle: The bundle holding the string catalog. Defaults to the SDK's own resource bundle.
  ///   - locale: The locale to translate into. Defaults to the localization the bundle itself
  ///     resolves to, so the copy matches the language the rest of the bundle's views render in:
  ///     `Locale.current` follows the device's first language, which the bundle may not ship
  ///     while a later preference is, and the two then disagree on one screen.
  static func message(for error: Error, bundle: Bundle = .module, locale: Locale? = nil) -> String {
    guard let apiError = error as? ClerkAPIError else {
      return error.localizedDescription
    }

    for key in localizationKeys(for: apiError) {
      if let translation = translation(forKey: key, bundle: bundle, locale: locale) {
        return translation
      }
    }

    return apiError.longMessage ?? apiError.message ?? apiError.localizedDescription
  }

  /// The locale a bundle's own views render in: its first preferred localization.
  ///
  /// Not `Locale.current`, which follows the device's first language even when the bundle does
  /// not ship it and a later preference is; the two then disagree on one screen.
  static func preferredLocale(of bundle: Bundle = .module) -> Locale {
    Locale(identifier: bundle.preferredLocalizations.first ?? "en")
  }

  /// The catalog keys to try for `error`, most specific first.
  private static func localizationKeys(for error: ClerkAPIError) -> [String] {
    var keys: [String] = []

    if let paramName = error.meta?["param_name"]?.stringValue, !paramName.isEmpty {
      keys.append("clerk_error_\(error.code)__\(paramName)")
    }

    keys.append("clerk_error_\(error.code)")
    return keys
  }

  /// The catalog's value for `key`, or `nil` when the catalog has no entry for it.
  ///
  /// A string catalog echoes the key back when it holds no translation, which is how a miss is
  /// detected here. Error codes are never user-facing copy, so an echoed key is unambiguous.
  private static func translation(forKey key: String, bundle: Bundle, locale: Locale?) -> String? {
    // `stringLiteral:` is the only initializer that accepts a key assembled at runtime. Error
    // codes and parameter names are `[a-z0-9_]`, so the key can never be read as a format string.
    let resource = LocalizedStringResource(
      String.LocalizationValue(stringLiteral: key),
      table: nil,
      locale: locale ?? preferredLocale(of: bundle),
      bundle: .atURL(bundle.bundleURL),
      comment: ""
    )

    let value = String(localized: resource)
    return value == key ? nil : value
  }
}
