import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.onChanged,
    this.validator,
    this.hintText,
    this.initialValue,
    this.controller,
    this.iconAndCursorColor,
    this.style,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? hintText;

  final String? initialValue;
  final TextEditingController? controller;

  /// Color to be used for the icon and cursor
  final Color? iconAndCursorColor;

  final TextStyle? style;

  final ValueChanged<String>? onFieldSubmitted;

  final FocusNode? focusNode;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: widget.iconAndCursorColor,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: widget.style,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: _isObscure
              ? appIcons.eyeSlash.svg(
                  color: widget.iconAndCursorColor,
                )
              : appIcons.eye.svg(
                  color: widget.iconAndCursorColor,
                ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),

        // prefix: gaIcons.mail.image(),
      ),
      keyboardType: TextInputType.visiblePassword,
      initialValue: widget.initialValue,
      controller: widget.controller,
      obscureText: _isObscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
