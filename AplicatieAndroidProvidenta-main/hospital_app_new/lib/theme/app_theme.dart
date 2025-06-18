import 'package:flutter/material.dart';

class AppTheme {
  // Primary color palette based on the blue wrench icon and maintenance theme
  static const Color primaryBlue = Color(0xFF0175C2); // Main blue from the icon
  static const Color darkBlue = Color(0xFF003F73); // Darker blue for contrast
  static const Color lightBlue = Color(0xFF4A9FE7); // Lighter blue for accents
  static const Color accentBlue = Color(0xFF1B8CDB); // Medium blue for highlights

  // Industrial/maintenance color palette
  static const Color steelGray = Color(0xFF6B7280); // Professional gray
  static const Color lightGray = Color(0xFFF3F4F6); // Background gray
  static const Color mediumGray = Color(0xFF9CA3AF); // Medium gray for secondary text
  static const Color darkGray = Color(0xFF374151); // Text gray
  static const Color charcoal = Color(0xFF1F2937); // Deep gray for headers

  // Status colors for maintenance reports
  static const Color successGreen = Color(0xFF10B981); // For completed/resolved
  static const Color warningOrange = Color(0xFFF59E0B); // For in-progress
  static const Color errorRed = Color(0xFFEF4444); // For issues/urgent
  static const Color infoBlue = Color(0xFF3B82F6); // For new items

  // Surface and background colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: accentBlue,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkGray,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: steelGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: darkGray.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: steelGray.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: steelGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: steelGray),
        hintStyle: TextStyle(color: steelGray.withValues(alpha: 0.7)),
        prefixIconColor: steelGray,
        suffixIconColor: steelGray,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        labelStyle: const TextStyle(color: darkGray),
        selectedColor: primaryBlue,
        deleteIconColor: steelGray,
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: steelGray,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 16,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: surfaceWhite,
        selectedTileColor: primaryBlue.withValues(alpha: 0.1),
        iconColor: steelGray,
        textColor: darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: steelGray,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: steelGray,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: steelGray,
          letterSpacing: 0.5,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundLight,

      // Remove splash effects for cleaner interactions
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  // Status colors for reports
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nou':
      case 'new':
        return infoBlue;
      case 'în progres':
      case 'in progress':
        return warningOrange;
      case 'rezolvat':
      case 'resolved':
      case 'completed':
        return successGreen;
      case 'urgent':
      case 'high priority':
        return errorRed;
      default:
        return steelGray;
    }
  }

  // Helper method to get icon for status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'nou':
      case 'new':
        return Icons.fiber_new_rounded;
      case 'în progres':
      case 'in progress':
        return Icons.autorenew_rounded;
      case 'rezolvat':
      case 'resolved':
      case 'completed':
        return Icons.check_circle_rounded;
      case 'urgent':
      case 'high priority':
        return Icons.priority_high_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  // Helper method to get department/category icon
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'it':
        return Icons.computer_rounded;
      case 'instalatii electrice':
        return Icons.electrical_services_rounded;
      case 'instalatii sanitare':
        return Icons.plumbing_rounded;
      case 'feronerie/usi/geamuri':
        return Icons.door_front_door_rounded;
      case 'mobilier/paturi':
        return Icons.bed_rounded;
      case 'aparatura medicala':
        return Icons.medical_services_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}