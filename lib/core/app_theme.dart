import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

abstract final class AppTheme {
  static const fontFamily = 'IBMPlexSansArabic';

  static final light = _build(FTheme.neutral.light.touch.colors);
  static final dark = _build(FTheme.neutral.dark.touch.colors);

  static FThemeData of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  static FThemeData _build(FColors colors) {
    final typeface = FTypeface.inherit(colors: colors, touch: true, fontFamily: fontFamily);
    return FThemeData(
      colors: colors,
      touch: true,
      typography: FTypography(display: typeface, body: typeface),
    );
  }
}
