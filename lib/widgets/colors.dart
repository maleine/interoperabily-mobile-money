import 'package:flutter/material.dart';

class ColorTheme {
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  static const Color pinkAccentColor = Colors.pinkAccent;

  // Définir un dégradé de couleur
  static const LinearGradient focusedGradient = LinearGradient(
    colors: [
      Color(0xFF04748C),
      Color(0xFF024A59),
      Color(0xFF023540),
      Color(0xFF012026),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color transparentColor = Colors.transparent;
  static const Color greenColor = Colors.green;
  static const Color phoneColor = Color.fromARGB(255, 197, 255, 202);
  static const Color googleColor = Color.fromARGB(255, 234, 240, 236);
  static const Color commonColor = Color.fromARGB(255, 252, 225, 233);
}
