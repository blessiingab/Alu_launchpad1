import 'package:flutter/material.dart';

/// Design tokens for ALU VentureLink.
///
/// "Savanna at Dusk" palette — warm ink/canvas neutrals with a deep navy
/// and gold accent, for an African Modernism feel. Supports both light
/// and dark mode. Uses the platform's default system font only.
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF16243D);
  static const Color navyLight = Color(0xFF243659);
  static const Color navyDeep = Color(0xFF0D1829);
  static const Color gold = Color.fromARGB(255, 204, 133, 25);
  static const Color goldDeep = Color.fromARGB(255, 96, 63, 13);
  static const Color goldPale = Color.fromARGB(255, 240, 211, 160);

  // Light surfaces
  static const Color canvas = Color(0xFFFAF8F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1ECE2); // subtle recessed panels
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkMuted = Color(0xFF5C6472);
  static const Color line = Color(0xFFE6E1D8);

  // Dark surfaces
  static const Color canvasDark = Color(0xFF11151C);
  static const Color cardDark = Color(0xFF1C222C);
  static const Color surfaceAltDark = Color(0xFF252C38);
  static const Color inkOnDark = Color(0xFFF3F1EC);
  static const Color inkMutedOnDark = Color(0xFFA7AFBC);
  static const Color lineDark = Color(0xFF2E3542);

  // Semantic
  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFD98E1F);
  static const Color danger = Color(0xFFC0463C);

  // Status badges
  static const Color pending = Color(0xFFD98E1F);
  static const Color verified = Color(0xFF2E8B57);
  static const Color rejected = Color(0xFFC0463C);

  static const LinearGradient duskGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, goldDeep],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient duskGradientSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy, navyLight],
  );

  /// Used for the Discover screen's "Recommended" hero card — a richer,
  /// four-stop version of duskGradient so it reads as a distinct,
  /// premium surface rather than a repeat of the standard brand gradient.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, goldDeep, gold],
    stops: [0.0, 0.45, 0.85, 1.0],
  );
}

/// Spacing scale — use instead of ad-hoc EdgeInsets values.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner radius scale — use instead of ad-hoc BorderRadius values.
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Motion durations — keep transitions consistent across the app.
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Soft, low-opacity shadows — used sparingly, since most surfaces rely
/// on a hairline border (AppColors.line) rather than elevation.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> raised(Color shadowColor) => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color ink, Color inkMuted) {
    // System font only — sizes/weights/letter-spacing follow the
    // Material 3 type scale, tightened slightly on large sizes for a
    // more editorial, less default-Android feel.
    return TextTheme(
      displayLarge: TextStyle(
        color: ink,
        fontSize: 57,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
      ),
      displayMedium: TextStyle(
        color: ink,
        fontSize: 45,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        color: ink,
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        color: ink,
        fontSize: 28,
        height: 1.22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        color: ink,
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: ink,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: ink,
        fontSize: 16,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodyMedium: TextStyle(
        color: inkMuted,
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodySmall: TextStyle(
        color: inkMuted,
        fontSize: 12,
        height: 1.45,
        letterSpacing: 0.15,
      ),
      labelLarge: TextStyle(
        color: ink,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: inkMuted,
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        color: inkMuted,
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static ThemeData get light => _build(
        brightness: Brightness.light,
        canvas: AppColors.canvas,
        card: AppColors.card,
        surfaceAlt: AppColors.surfaceAlt,
        ink: AppColors.ink,
        inkMuted: AppColors.inkMuted,
        line: AppColors.line,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        canvas: AppColors.canvasDark,
        card: AppColors.cardDark,
        surfaceAlt: AppColors.surfaceAltDark,
        ink: AppColors.inkOnDark,
        inkMuted: AppColors.inkMutedOnDark,
        line: AppColors.lineDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color canvas,
    required Color card,
    required Color surfaceAlt,
    required Color ink,
    required Color inkMuted,
    required Color line,
  }) {
    final isDark = brightness == Brightness.dark;
    final accent = isDark ? AppColors.gold : AppColors.navy;
    final onAccent = isDark ? AppColors.navyDeep : Colors.white;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        brightness: brightness,
        primary: accent,
        onPrimary: onAccent,
        secondary: AppColors.gold,
        onSecondary: AppColors.navyDeep,
        tertiary: AppColors.goldDeep,
        surface: card,
        onSurface: ink,
        surfaceContainerHighest: surfaceAlt,
        error: AppColors.danger,
        onError: Colors.white,
        outline: line,
      ),
      scaffoldBackgroundColor: canvas,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = _textTheme(ink, inkMuted);

    return base.copyWith(
      textTheme: textTheme,
      iconTheme: IconThemeData(color: inkMuted, size: 22),
      primaryIconTheme: IconThemeData(color: accent, size: 22),

      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: ink),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: line),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: DividerThemeData(
        color: line,
        thickness: 1,
        space: AppSpacing.xl,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: inkMuted.withValues(alpha: 0.7)),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: accent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          disabledBackgroundColor: line,
          disabledForegroundColor: inkMuted,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
          animationDuration: AppMotion.fast,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(onAccent.withValues(alpha: 0.08)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: inkMuted,
          highlightColor: accent.withValues(alpha: 0.08),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: accent,
        disabledColor: line,
        labelStyle: textTheme.labelMedium?.copyWith(color: ink),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: onAccent),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: inkMuted,
        textColor: ink,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : line,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent.withValues(alpha: 0.4)
              : surfaceAlt,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : Colors.transparent,
        ),
        side: BorderSide(color: inkMuted, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : inkMuted,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: accent.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? accent : inkMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? accent : inkMuted, size: 24);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 64,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceAlt : AppColors.navy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.inkOnDark : Colors.white,
        ),
        actionTextColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? surfaceAlt : AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.inkOnDark : Colors.white,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: inkMuted,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
        indicatorColor: accent,
        dividerColor: line,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: line,
        circularTrackColor: line,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navyDeep,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(inkMuted.withValues(alpha: 0.3)),
        radius: const Radius.circular(AppRadius.pill),
        thickness: WidgetStateProperty.all(4),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          
        },
      ),
    );
  }
}