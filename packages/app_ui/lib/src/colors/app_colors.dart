import 'dart:ui';

/// [Color]s used in the app (food delivery style)
abstract class AppColors {
  // Base colors
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Brand palette (extracted from provided designs)
  // Primary is a warm red; accent is a bright orange used for CTAs
  static const primary = Color(0xFFE53935); // red 600
  static const primaryDark = Color(0xFFB71C1C);
  static const primaryLight = Color(0xFFFF6B5E);

  static const accent = Color(0xFFFF8A00);
  static const accentLight = Color(0xFFFFC266);

  // Gradients
  static const gradientStart = Color(0xFFE53935); // red
  static const gradientEnd = Color(0xFFF97316); // orange

  // Status colors
  static const success = Color(0xFF22C55E); // green 500
  static const successLight = Color(0xFFA7F3D0);
  static const error = Color(0xFFEF4444); // red 500
  static const errorLight = Color(0xFFFCA5A5);
  static const warning = Color(0xFFF59E0B); // amber 500
  static const warningLight = Color(0xFFFDE68A);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF93C5FD);

  // Greys tuned for soft food UI
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF4F4F5);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD4D4D8);
  static const grey400 = Color(0xFFA1A1AA);
  static const grey500 = Color(0xFF71717A);
  static const grey600 = Color(0xFF52525B);
  static const grey700 = Color(0xFF3F3F46);
  static const grey800 = Color(0xFF27272A);
  static const grey900 = Color(0xFF18181B);

  // Semantic aliases
  static const background = Color(0xFFFDFDFD); // near-white canvas
  static const surface = white; // cards/sheets
  static const textPrimary = grey900;
  static const textSecondary = grey600;
  static const textDisabled = grey400;
  static const border = grey200;
  static const divider = grey200;
  static const scaffoldBackground = Color(0xFFF7F7F7);
}
