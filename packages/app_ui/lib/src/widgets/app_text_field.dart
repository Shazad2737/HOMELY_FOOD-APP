import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.onChanged,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.suffixIcon,
    this.inputFormatters = const [],
    this.validator,
    this.hintText,
    this.centreText = false,
    this.initialValue,
    this.style,
    this.minLines,
    this.maxLines,
    super.key,
  });

  final TextEditingController? controller;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? hintText;

  final bool centreText;

  final String? initialValue;

  final TextStyle? style;

  final int? minLines;

  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      // style: Theme.of(context).textTheme.titleMedium?.copyWith(
      //       height: 1,
      //     ),
      style: style,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      textAlign: centreText ? TextAlign.center : TextAlign.start,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        hintText: hintText,
        hintStyle: style?.copyWith(
          color: style?.color?.withOpacity(0.4),
        ),
        // hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        //       color: Colors.grey,
        //     ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
