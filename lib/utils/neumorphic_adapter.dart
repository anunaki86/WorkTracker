import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// Adapter dla pakietu Flutter Neumorphic, który rozwiązuje problemy kompatybilności
/// z nowszymi wersjami Flutter.
class NeumorphicThemeAdapter {
  /// Tworzy motyw Neumorphic kompatybilny z nowszymi wersjami Flutter
  static NeumorphicThemeData createTheme(BuildContext context, {bool isDark = false}) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    
    final baseTheme = NeumorphicThemeData(
      baseColor: baseColor,
      lightSource: LightSource.topLeft,
      depth: 10,
      intensity: 0.5,
    );
    
    // Dodajemy brakujące właściwości
    return baseTheme.copyWith(
      defaultTextColor: isDark ? Colors.white : Colors.black87,
      textTheme: _createTextTheme(context, isDark),
    );
  }
  
  /// Tworzy motyw tekstu kompatybilny z nowszymi wersjami Flutter
  static TextTheme _createTextTheme(BuildContext context, bool isDark) {
    final baseTextTheme = Theme.of(context).textTheme;
    final color = isDark ? Colors.white : Colors.black87;
    
    return baseTextTheme.copyWith(
      // Używamy nowych nazw właściwości zamiast przestarzałych (headline5 -> headlineSmall)
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: color),
      // bodyText2 -> bodyMedium
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: color),
    );
  }
}

/// Rozszerzenie dla AppBarTheme, które dodaje brakujące właściwości
extension AppBarThemeExtension on AppBarTheme {
  /// Tworzy AppBarTheme kompatybilny z nowszymi wersjami Flutter
  static AppBarTheme createCompatible({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    TextStyle? titleTextStyle,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      titleTextStyle: titleTextStyle,
    );
  }
}

/// Własna implementacja NeumorphicDialog, która jest kompatybilna z nowszymi wersjami Flutter
class CustomNeumorphicDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  
  const CustomNeumorphicDialog({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(16),
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Neumorphic(
        style: const NeumorphicStyle(
          depth: 4,
          intensity: 0.6,
          shape: NeumorphicShape.flat,
        ),
        margin: margin,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Własna implementacja NeumorphicButton, która jest kompatybilna z nowszymi wersjami Flutter
class CustomNeumorphicButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final NeumorphicStyle? style;
  
  const CustomNeumorphicButton({
    super.key,
    this.child,
    this.onPressed,
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    // Zastąpienie NeumorphicButton standardowym ElevatedButton
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

/// Własna implementacja NeumorphicTextField, która jest kompatybilna z nowszymi wersjami Flutter
class CustomNeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  
  const CustomNeumorphicTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        depth: -3,
        intensity: 0.7,
        shape: NeumorphicShape.flat,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: 
      // Zastąpienie NeumorphicTextField standardowym TextFormField
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
