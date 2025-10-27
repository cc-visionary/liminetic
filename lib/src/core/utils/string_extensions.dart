// lib/src/core/utils/string_extensions.dart

/// A collection of utility extension methods for the String class.
extension StringExtension on String {
  /// Returns a new string with the first letter capitalized.
  /// Example: "visitorEntry" becomes "VisitorEntry".
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
