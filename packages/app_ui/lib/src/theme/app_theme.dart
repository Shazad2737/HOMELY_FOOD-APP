import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// {@template ga_theme}
/// The default [ThemeData].
/// {@endtemplate}
class AppTheme {
  /// Food app `ThemeData` based on the provided designs.
  static ThemeData get standard {
    final baseTextTheme = _textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ).copyWith(
        primary: AppColors.primary, // #FD9D02 CTA bg (auth)
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent, // link text
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.accentContainer, // see-all bg
        tertiary: AppColors.appRed, // order now / active tab
        onTertiary: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: baseTextTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      datePickerTheme: _datePickerTheme,
      cardTheme: _cardTheme,
      drawerTheme: _drawerTheme,
      dividerTheme: _dividerTheme,
      iconTheme: const IconThemeData(color: AppColors.grey700),
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      chipTheme: _chipTheme,
      dropdownMenuTheme: _dropdownMenuTheme,
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.white,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppSemanticsTheme(),
      ],
    );
  }

  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.white,
      shape: CircleBorder(),
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      foregroundColor: AppColors.textPrimary,
      backgroundColor: AppColors.white,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    final borderRadius = BorderRadius.circular(15);
    return InputDecorationTheme(
      // fillColor: AppColors.grey50,
      // filled: true,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: borderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: borderRadius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: borderRadius,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: borderRadius,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      hoverColor: Colors.transparent,
      suffixIconColor: AppColors.grey600,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: const WidgetStatePropertyAll(AppColors.white),
        textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      ),
    );
  }

  static FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.white),
        textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textStyle: WidgetStatePropertyAll(AppTextStyles.labelLarge),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.primary, width: 1.5),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.accent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static DatePickerThemeData get _datePickerTheme {
    return DatePickerThemeData(
      // backgroundColor: AppColors.white,
      rangePickerHeaderHelpStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.white,
      ),
      headerHelpStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.white,
      ),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      shadowColor: AppColors.grey300.withValues(alpha: 0.5),
      margin: EdgeInsets.zero,
    );
  }

  static DrawerThemeData get _drawerTheme {
    return const DrawerThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      width: 280,
    );
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.appRed,
      unselectedItemColor: AppColors.grey400,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      showUnselectedLabels: true,
    );
  }

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.white,
      disabledColor: AppColors.grey100,
      selectedColor: AppColors.appGreen,
      secondarySelectedColor: AppColors.appGreen,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      secondaryLabelStyle:
          AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      brightness: Brightness.light,
    );
  }

  static DropdownMenuThemeData get _dropdownMenuTheme {
    return DropdownMenuThemeData(
      textStyle: AppTextStyles.bodySmall,
      inputDecorationTheme: _inputDecorationTheme,
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: const WidgetStatePropertyAll(4),
        backgroundColor: const WidgetStatePropertyAll(AppColors.white),
      ),
    );
  }
}

@immutable
class AppSemanticsTheme extends ThemeExtension<AppSemanticsTheme> {
  const AppSemanticsTheme({
    this.success = AppColors.success,
    this.onSuccess = AppColors.white,
    this.warning = AppColors.warning,
    this.onWarning = AppColors.white,
    this.info = AppColors.info,
    this.onInfo = AppColors.white,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  @override
  AppSemanticsTheme copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppSemanticsTheme(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppSemanticsTheme lerp(ThemeExtension<AppSemanticsTheme>? other, double t) {
    if (other is! AppSemanticsTheme) return this;
    return AppSemanticsTheme(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}
