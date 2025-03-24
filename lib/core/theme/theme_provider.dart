// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Box _prefsBox = Hive.box('scoreBox'); // Aynı Hive box'ı kullanıyoruz
  
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }
  
  void _loadTheme() {
    final isDark = _prefsBox.get('isDarkMode', defaultValue: false) as bool?;
    state = isDark == true ? ThemeMode.dark : ThemeMode.light;
  }
  
  Future<void> toggleTheme() async {
    final newState = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefsBox.put('isDarkMode', newState == ThemeMode.dark);
    state = newState;
  }
}

// Aydınlık tema
ThemeData getLightTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Colors.grey[100]!,
      error: Colors.red,
    ),
  );
}

// Karanlık tema
ThemeData getDarkTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[850],
      shadowColor: Colors.black.withOpacity(0.4),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey[850],
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey[850],
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[400]!,
      secondary: Colors.blueAccent[400]!,
      surface: Colors.grey[850]!,
      background: const Color(0xFF121212),
      error: Colors.red[400]!,
    ),
  );
}

// Hücre renklerini aktif temaya göre döndüren extension
extension ThemeColors on BuildContext {
  Color getCellBackgroundColor(ThemeMode mode, Color lightColor) {
    if (mode == ThemeMode.dark) {
      if (lightColor == Colors.white) return Colors.grey[850]!;
      if (lightColor == Colors.red[200]) return Colors.red[900]!;
      if (lightColor.value == Colors.green.withOpacity(0.3).value) return Colors.green[900]!;
      if (lightColor == Colors.grey[350]) return Colors.grey[700]!;
    }
    return lightColor;
  }
  
  Color getCellTextColor(ThemeMode mode) {
    return mode == ThemeMode.dark ? Colors.white : Colors.black;
  }
}