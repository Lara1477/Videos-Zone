import 'package:material_ui/material_ui.dart';

const kGround = Color(0xFF0E0E10);
const kSurface = Color(0xFF1A1A1F);
const kBorder = Color(0xFF2E2E35);
const kAccent = Color(0xFFC6F432);
const kMuted = Color(0xFFB8B8C0);

ThemeData buildTheme() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: kBorder),
  );
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kGround,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      onPrimary: kGround,
      surface: kGround,
      error: Color(0xFFFF6B81),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: kAccent, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9A9AA3)),
    ),
  );
}
