String formatDouble(num value, {int decimalPlaces = 2}) {
  // Use toStringAsFixed to limit to 2 decimal places initially
  final formatted = value.toStringAsFixed(decimalPlaces);

  // Convert it back to double to remove any trailing zeros
  final temp = double.parse(formatted);

  // If the number is an integer, return it as an integer
  if (temp % 1 == 0) {
    return temp.toInt().toString();
  }

  // Convert back to string; this removes trailing zeros
  return temp.toString();
}

extension DoubleX on num {
  /// Formats a double to a string with the specified number of decimal places
  /// and removes trailing zeros.
  String toStringAsFixedFormatted([
    int decimalPlaces = 2,
  ]) =>
      formatDouble(this, decimalPlaces: decimalPlaces);
}
