import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme;
  static const String _themeKey = 'selectedTheme'; // Clave para guardar el tema

  ThemeNotifier(this._currentTheme) {
    _loadThemeFromPreferences(); // Cargar tema al iniciar
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> setTheme(ThemeData theme, int themeIndex) async {
    _currentTheme = theme;
    notifyListeners();

    // Guardar el índice del tema en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeIndex);
  }

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = prefs.getInt(_themeKey) ?? 0;

    // Lista de temas
    List<ThemeData> themes = [theme1, theme2, theme3, theme4];
    _currentTheme = themes[themeIndex]; // Asignar el tema guardado
    notifyListeners();
  }
}

final ThemeData theme1 = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Color.fromARGB(255, 167, 106, 228),
    secondary: Color.fromARGB(66, 194, 148, 232),
    tertiary: const Color.fromARGB(255, 167, 106, 228),
  ),
);

final ThemeData theme2 = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFFD36AE4),
      secondary: const Color(0x42E894BC),
      tertiary:
          const Color.fromARGB(255, 214, 113, 229) //Color para los botones
      ),
);

final ThemeData theme3 = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color.fromARGB(255, 212, 106, 228),
      secondary: const Color.fromARGB(66, 200, 148, 232),
      tertiary: const Color.fromARGB(255, 210, 113, 229)),
);
final ThemeData theme4 = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color.fromARGB(255, 106, 157, 228),
      secondary: const Color.fromARGB(66, 148, 229, 232),
      tertiary: const Color.fromARGB(255, 113, 184, 229)),
);
