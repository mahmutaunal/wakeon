import 'package:flutter/services.dart';

/// Formats user input as a standard MAC address (AA:BB:CC:DD:EE:FF).
class MacAddressInputFormatter extends TextInputFormatter {
  const MacAddressInputFormatter();

  /// Normalizes input and automatically inserts MAC address separators.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep hexadecimal characters only and normalize them to uppercase.
    final cleanValue = newValue.text
        .replaceAll(RegExp(r'[^A-Fa-f0-9]'), '')
        .toUpperCase();

    final buffer = StringBuffer();

    for (var index = 0; index < cleanValue.length && index < 12; index++) {
      if (index > 0 && index % 2 == 0) {
        // Insert separators after every byte pair.
        buffer.write(':');
      }

      buffer.write(cleanValue[index]);
    }

    final formattedValue = buffer.toString();

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
