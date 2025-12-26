import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// A sophisticated international phone input widget with country selection.
///
/// Features:
/// - International country selector with bottom sheet
/// - India as default country
/// - India and Middle East countries prioritized in selector
/// - Automatic phone number parsing and validation
/// - Beautiful UI consistent with app design system
/// - Error state handling
class InternationalPhoneInput extends StatefulWidget {
  const InternationalPhoneInput({
    required this.onChanged,
    this.initialValue,
    this.errorText,
    this.label,
    super.key,
  });

  /// Initial phone number value (can be with or without country code)
  final String? initialValue;

  /// Error message to display
  final String? errorText;

  /// Label text for the field
  final String? label;

  /// Callback when phone number changes (returns full international format)
  final void Function(String phoneNumber) onChanged;

  @override
  State<InternationalPhoneInput> createState() =>
      _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInput> {
  PhoneNumber? _initialValue;
  late TextEditingController _controller;

  // Default to India
  static const _defaultDialCode = '91';
  static const _defaultIsoCode = 'IN';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _setupInitialValue();
  }

  void _setupInitialValue() {
    final initialValue = widget.initialValue;

    if (initialValue != null && initialValue.isNotEmpty) {
      // Set UAE as default, parse phone number without country detection
      if (mounted) {
        setState(() {
          _initialValue = PhoneNumber(
            dialCode: _defaultDialCode,
            isoCode: _defaultIsoCode,
            phoneNumber: initialValue.startsWith('+')
                ? initialValue
                : '+$_defaultDialCode$initialValue',
          );
        });

        final cleanNumber = initialValue
            .replaceFirst('+', '')
            .replaceFirst(_defaultDialCode, '');
        _controller.text = cleanNumber;
      }
    } else {
      // No initial value, set default UAE country
      if (mounted) {
        setState(() {
          _initialValue = PhoneNumber(
            dialCode: _defaultDialCode,
            isoCode: _defaultIsoCode,
            phoneNumber: '',
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.label!,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.errorText != null
                  ? colorScheme.error
                  : colorScheme.outline.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Theme(
            data: theme.copyWith(
              // Style the bottom sheet for country selection
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            child: InternationalPhoneNumberInput(
              textFieldController: _controller,
              initialValue: _initialValue,
              spaceBetweenSelectorAndTextField: 0,
              selectorTextStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              inputDecoration: InputDecoration(
                hintText: '9xxx xxx xxx',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                prefixStyle: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
              selectorConfig: SelectorConfig(
                useBottomSheetSafeArea: true,
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                setSelectorButtonAsPrefixIcon: true,
                leadingPadding: 12,
                trailingSpace: false,
                useEmoji: true,

                // Prioritize India and Middle East countries
                countryComparator: (a, b) {
                  const priorityCountries = [
                    'IN', // India
                    'AE', // UAE
                    'SA', // Saudi Arabia
                    'QA', // Qatar
                    'BH', // Bahrain
                    'OM', // Oman
                    'KW', // Kuwait
                  ];

                  final aIndex = priorityCountries.indexOf(a.alpha2Code ?? '');
                  final bIndex = priorityCountries.indexOf(b.alpha2Code ?? '');

                  if (aIndex != -1 && bIndex != -1) {
                    return aIndex.compareTo(bIndex);
                  }
                  if (aIndex != -1) return -1;
                  if (bIndex != -1) return 1;

                  // Default alphabetical
                  return (a.name ?? '').compareTo(b.name ?? '');
                },
              ),
              onInputChanged: (PhoneNumber value) {
                if (value.phoneNumber == null || value.phoneNumber!.isEmpty) {
                  return;
                }
                widget.onChanged(value.phoneNumber!);
              },
              onSaved: (PhoneNumber value) {
                if (value.phoneNumber != null &&
                    value.phoneNumber!.isNotEmpty) {
                  widget.onChanged(value.phoneNumber!);
                }
              },
              ignoreBlank: true,
              cursorColor: colorScheme.primary,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.errorText!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
