import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
    required this.icon,
    required this.text,
    required this.color,
    super.key,
  });

  final Widget icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,

          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
