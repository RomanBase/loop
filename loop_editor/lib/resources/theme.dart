import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_control/control.dart';

const _fontFamily = 'Roboto';
const _fontHeadlineFamily = 'Roboto';

const _fontSpacing = 0.25;
const _fontHeadlineSpacing = 0.0;

const _fontHeight = 1.35;
const _fontContentHeight = 1.6;
const _fontHeadlineHeight = 1.1;

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  surface: Colors.white,
  onSurface: Colors.black,
  background: Colors.white,
  onBackground: Colors.black,
  primary: Color(0xFF252525),
  primaryContainer: Color(0xFF252525),
  onPrimary: Colors.white,
  secondary: Color(0xFF0075A1),
  secondaryContainer: Color(0xFFA1E1FF),
  onSecondary: Colors.white,
  onSecondaryContainer: Color(0xFF0075A1),
  tertiary: Color(0xFFA3AAB7),
  tertiaryContainer: Color(0xFF353535),
  onTertiary: Colors.black,
  error: Color(0xFFE60005),
  errorContainer: Color(0x50E60005),
  onError: Colors.white,
  shadow: Color(0x338DCFE8),
  outline: Color(0xFFEAEDF3),
  outlineVariant: Color(0xFFA3AAB7),
);

const _darkScheme = _lightScheme;

TextTheme _textTheme(Color color) => TextTheme(
      displayLarge: TextStyle(fontSize: 48.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      displayMedium: TextStyle(fontSize: 40.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      displaySmall: TextStyle(fontSize: 32.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      headlineLarge: TextStyle(fontSize: 28.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      headlineMedium: TextStyle(fontSize: 24.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      headlineSmall: TextStyle(fontSize: 20.0, color: color, fontFamily: _fontHeadlineFamily, fontWeight: FontWeight.w900, height: _fontHeadlineHeight, letterSpacing: _fontHeadlineSpacing),
      titleLarge: TextStyle(fontSize: 22.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w800, height: _fontHeight, letterSpacing: _fontSpacing),
      titleMedium: TextStyle(fontSize: 18.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w800, height: _fontHeight, letterSpacing: _fontSpacing),
      titleSmall: TextStyle(fontSize: 16.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w700, height: _fontHeight, letterSpacing: _fontSpacing),
      bodyLarge: TextStyle(fontSize: 14.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w400, height: _fontContentHeight, letterSpacing: _fontSpacing),
      bodyMedium: TextStyle(fontSize: 13.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w400, height: _fontContentHeight, letterSpacing: _fontSpacing),
      bodySmall: TextStyle(fontSize: 12.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w300, height: _fontContentHeight, letterSpacing: _fontSpacing),
      labelLarge: TextStyle(fontSize: 15.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w700, height: _fontHeight, letterSpacing: _fontSpacing),
      labelMedium: TextStyle(fontSize: 14.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w700, height: _fontContentHeight, letterSpacing: _fontSpacing),
      labelSmall: TextStyle(fontSize: 12.0, color: color, fontFamily: _fontFamily, fontWeight: FontWeight.w700, height: _fontContentHeight, letterSpacing: _fontSpacing),
    );

ThemeData _light() => ThemeData.from(
      useMaterial3: true,
      colorScheme: _lightScheme,
      textTheme: _textTheme(_lightScheme.secondary),
    ).copyWith(
      primaryTextTheme: _textTheme(_lightScheme.primary),
      dividerColor: const Color(0xFFEAEDF3),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(
          color: _lightScheme.secondary.withOpacity(0.5),
        ),
      ),
    );

ThemeData _dark() => ThemeData.from(
      useMaterial3: true,
      colorScheme: _darkScheme,
      textTheme: _textTheme(_darkScheme.secondary),
    ).copyWith(
      primaryTextTheme: _textTheme(_darkScheme.primary),
      dividerColor: const Color(0xFFEAEDF3),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(
          color: _darkScheme.secondary.withOpacity(0.5),
        ),
      ),
    );

class UISize {
  const UISize._();

  static double get topBorderSize => UITheme.device.topBorderSize;

  static double get bottomBorderSize => UITheme.device.bottomBorderSize;

  static const quad = 4.0;
  static const half = 8.0;
  static const quarter = 12.0;
  static const padding = 16.0;
  static const mid = 24.0;
  static const extended = 32.0;
  static const bounds = 48.0;
  static const section = 64.0;

  static const iconSmall = 18.0;
  static const icon = 24.0;
  static const iconLarge = 32.0;
  static const iconBounds = 48.0;
  static const iconLauncher = 144.0;

  static const control = 42.0;
  static const barHeight = 56.0;
  static const buttonHeight = 56.0;
  static const inputHeight = 48.0;
  static const inputAreaHeight = 92.0;
  static const inputWidth = 256.0;

  static const thumb = 96.0;
  static const preview = 192.0;
  static const head = 420.0;
  static const headPreview = 240.0;

  static const divider = 1.0;

  static const itemRadius = 6.0;
  static const cardRadius = 12.0;
  static const actionScaleRatio = 0.95;

  static const tileSize = 256.0;
  static const buttonRadius = 6.0;
  static const iconSizeLogo = 32.0;
  static const dialogWidth = 320.0;

  static const minContentArea = 320.0;
  static const maxFrameArea = 640.0;
  static const maxContentArea = 1280.0;

  static const blurSigma = 12.0;
}

extension UITheme on ThemeData {
  static MaterialThemeFactory get factory => {
        Brightness.light: () => _light(),
        Brightness.dark: () => _dark(),
      };

  static late ColorScheme activeScheme;

  static late Device device;

  static void invalidate(RootContext context) {
    activeScheme = context<MaterialThemeConfig>()!.value.colorScheme;
    device = Device.of(context);
  }

  ColorScheme get scheme => colorScheme;

  TextTheme get font => textTheme;

  TextTheme get fontPrimary => primaryTextTheme;

  ScrollPhysics get platformPhysics => Device.onPlatform(
        android: () => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        ios: () => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        other: () => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        defaultValue: () => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      )!;

  ImageFilter get blurFilter => ImageFilter.blur(sigmaX: UISize.blurSigma, sigmaY: UISize.blurSigma);

  Color get shadowColor => colorScheme.shadow;

  BorderRadius get pageBorderRadius => const BorderRadius.vertical(top: Radius.circular(UISize.cardRadius));

  BorderRadius get cardBorderRadius => BorderRadius.circular(UISize.cardRadius);

  BoxDecoration get pageDecoration => BoxDecoration(
        borderRadius: pageBorderRadius,
        color: colorScheme.background,
      );

  BoxDecoration get cardDecoration => BoxDecoration(
        borderRadius: cardBorderRadius,
        color: colorScheme.background,
        boxShadow: cardShadow,
      );

  BoxDecoration get dividerDeco => BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dividerColor.withOpacity(0.25)),
        ),
      );

  BoxDecoration get chipDeco => BoxDecoration(
        border: Border.all(color: dividerColor.withOpacity(0.25)),
      );

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          offset: const Offset(0.0, 1.0),
          color: colorScheme.shadow,
          blurRadius: 8.0,
          spreadRadius: 4.0,
        ),
      ];

  List<BoxShadow> get itemShadow => [
        BoxShadow(
          offset: const Offset(0.0, 1.0),
          color: shadowColor.withOpacity(0.05),
          blurRadius: 8.0,
          spreadRadius: 4.0,
        ),
      ];
}

extension TextStyleExtension on TextStyle {
  TextStyle get onBackground => copyWith(color: UITheme.activeScheme.onBackground);

  TextStyle get onPrimary => copyWith(color: UITheme.activeScheme.onPrimary);

  TextStyle get onSecondary => copyWith(color: UITheme.activeScheme.onSecondary);

  TextStyle get onTertiary => copyWith(color: UITheme.activeScheme.onTertiary);

  TextStyle get onError => copyWith(color: UITheme.activeScheme.onError);

  TextStyle get primary => copyWith(color: UITheme.activeScheme.primary);

  TextStyle get secondary => copyWith(color: UITheme.activeScheme.secondary);

  TextStyle get tertiary => copyWith(color: UITheme.activeScheme.tertiary);

  TextStyle get error => copyWith(color: UITheme.activeScheme.error);

  TextStyle get onSurfaceVariant => copyWith(color: UITheme.activeScheme.onSurfaceVariant);

  TextStyle get asOutline => copyWith(color: UITheme.activeScheme.outline);

  TextStyle get asOutlineVariant => copyWith(color: UITheme.activeScheme.outlineVariant);

  TextStyle withOpacity(double opacity) => copyWith(color: color?.withOpacity(opacity));
}

extension ButtonStyleExtension on ButtonStyle {
  ButtonStyle get outline => copyWith(
        backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor: MaterialStatePropertyAll<Color>(backgroundColor?.resolve({}) ?? UITheme.activeScheme.primary),
        overlayColor: MaterialStatePropertyAll<Color>((backgroundColor?.resolve({}) ?? UITheme.activeScheme.primary).withOpacity(0.25)),
        shadowColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide(color: backgroundColor?.resolve({}) ?? UITheme.activeScheme.primary),
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      );

  ButtonStyle get error => copyWith(
        backgroundColor: MaterialStatePropertyAll<Color>(UITheme.activeScheme.error),
        overlayColor: MaterialStatePropertyAll<Color>((UITheme.activeScheme.onError).withOpacity(0.25)),
      );
}

extension ColorExt on Color {
  Color get tintOpacity => withOpacity(0.15);

  Color get accentOpacity => withOpacity(0.25);
}
