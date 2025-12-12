import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A beautiful, reusable phone input widget specifically for UAE phone numbers.
///
/// Features:
/// - Non-interactive country selector showing UAE flag and +971 code
/// - Clean, modern UI design
/// - Proper input formatting and validation
/// - Consistent with app's design system
class UaePhoneInput extends StatelessWidget {
  const UaePhoneInput({
    required this.onChanged,
    this.errorText,
    this.hintText = 'XX XXX XXXX',
    this.initialValue,
    super.key,
  });

  /// Callback when phone number changes
  final ValueChanged<String> onChanged;

  /// Error message to display
  final String? errorText;

  /// Placeholder text
  final String? hintText;

  /// Initial value for the field
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // UAE Country Selector (Non-interactive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // UAE Flag Emoji
                    const Text(
                      '🇦🇪',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    // Country Code
                    Text(
                      '+971',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(width: 2),
                    // Dropdown affordance (non-interactive)
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              // Vertical Divider
              Container(
                width: 1.5,
                height: 56,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              // Phone Number Input
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    _UaePhoneFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // Remove formatting and pass clean number
                    final cleanNumber = value.replaceAll(RegExp(r'\s+'), '');
                    // Prepend +971 to the clean number for validation
                    onChanged('+971$cleanNumber');
                  },
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom formatter for UAE phone numbers
/// Formats: 50 123 4567 or 52 345 6789
class _UaePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Remove all spaces
    final digitsOnly = text.replaceAll(RegExp(r'\s+'), '');

    // Build formatted string
    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      // Add space after 2nd and 5th digit
      if (i == 1 || i == 4) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
