import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monet/engine.dart' as engine;

/// The main class which handles platform communication and palette calculations.
///
/// This is the main entrypoint of the plugin and the recommended way to access the colors.
/// Call [MonetProvider.newInstance()] to get a running and working instance of this class.
///
/// It implements [ChangeNotifier] because it also listens for wallpaper changes
/// to update the colors automatically. It is possible to get notified by just calling
/// [addListener] and setting up your listener logic in there.
///
/// Note: If the platform is not supported the listener mechanism will not work.
class MonetProvider extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel("monet/colors");

  /// Whether the current platform supports wallpaper based monet.
  ///
  /// Only Android supports it, every other platform will generate a palette using a fallback color.
  static bool get isCurrentPlatformSupported {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid;
  }

  MonetProvider._(this._platformColors) {
    if (!isCurrentPlatformSupported) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == "updateColors") {
        _platformColors = _fromMap((call.arguments as Map).cast<String, int>());
        notifyListeners();
      }

      return null;
    });
  }

  /// Creates a new instance of [MonetProvider].
  ///
  /// It's recommended to store the returned instance for ease of use.
  static Future<MonetProvider> newInstance() async {
    return MonetProvider._(await _getPlatformColors());
  }

  MonetColors? _platformColors;

  /// Get the current platform provided colors or generates a new color collection
  /// from the provided [fallbackColor].
  ///
  /// The colors will get generated from [fallbackColor] if [isCurrentPlatformSupported] is false
  /// or if [useFallbackColor] is true.
  MonetColors getColors(
    Color fallbackColor, {
    bool useFallbackColor = false,
  }) {
    if (useFallbackColor) return _deriveColors(fallbackColor);

    return _platformColors ?? _deriveColors(fallbackColor);
  }

  MonetColors _deriveColors(Color color) {
    final engine.ColorScheme scheme = engine.DynamicColorScheme(
      targetColors: const engine.TargetColors(),
      primaryColor: engine.Srgb.fromColor(color),
    );

    return scheme.asColors;
  }

  static Future<MonetColors?> _getPlatformColors() async {
    if (!isCurrentPlatformSupported) return null;

    final Map<String, int>? rawData =
        await _channel.invokeMapMethod<String, int>("getCurrentColors");

    return _fromMap(rawData!);
  }

  static MonetColors _fromMap(Map<String, int> data) {
    final Map<int, Color> accent1 = {};
    final Map<int, Color> accent2 = {};
    final Map<int, Color> accent3 = {};
    final Map<int, Color> neutral1 = {};
    final Map<int, Color> neutral2 = {};

    data.forEach((key, value) {
      final String palette = key.split(".").first;
      final int shade = int.parse(key.split(".").last);

      switch (palette) {
        case "accent1":
          accent1[shade] = Color(value).withOpacity(1);
          break;
        case "accent2":
          accent2[shade] = Color(value).withOpacity(1);
          break;
        case "accent3":
          accent3[shade] = Color(value).withOpacity(1);
          break;
        case "neutral1":
          neutral1[shade] = Color(value).withOpacity(1);
          break;
        case "neutral2":
          neutral2[shade] = Color(value).withOpacity(1);
          break;
      }
    });

    return MonetColors(
      accent1: MonetPalette(accent1),
      accent2: MonetPalette(accent2),
      accent3: MonetPalette(accent3),
      neutral1: MonetPalette(neutral1),
      neutral2: MonetPalette(neutral2),
    );
  }
}

/// Represents a collection of [MonetPalette]s that are generated using the bundled in monet engine
///
/// Each [MonetPalette] contains a set of 13 shades of a base color.
/// The base color used for each palette depend on the engine itself.
class MonetColors {
  /// Main accent color. Generally, this is close to the primary color.
  final MonetPalette accent1;

  /// Secondary accent color. Darker shades of [accent1].
  final MonetPalette accent2;

  /// Tertiary accent color. Primary color shifted to the next secondary color via hue offset.
  final MonetPalette accent3;

  /// Main background color. Tinted with the primary color.
  final MonetPalette neutral1;

  /// Secondary background color. Slightly tinted with the primary color.
  final MonetPalette neutral2;

  /// Creates a new instance of [MonetColors].
  ///
  /// Usually there should be no need to call this manually as you can get
  /// an already instanced object by creating a new [MonetProvider] with [MonetProvider.newInstance()]
  /// and then calling [MonetProvider.colors].
  const MonetColors({
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.neutral1,
    required this.neutral2,
  });
}

/// A set of 13 shades of a base color that was derived from the monet engine color calculations.
class MonetPalette extends ColorSwatch<int> {
  /// The raw map contains a set of key/values with all the shades
  final Map<int, Color> colors;

  /// Creates a new [MonetPalette]. It's not recommended to use this constructor directly
  /// as working and ready instances are already provided by [MonetColors].
  MonetPalette(this.colors)
      : assert(colors.length == 13),
        super(colors[500]!.value, colors);

  /// Lightest shade of the palette, equals to white.
  Color get shade0 => this[0]!;

  /// Base color at 99% lightness.
  Color get shade10 => this[10]!;

  /// Base color at 95% lightness.
  Color get shade50 => this[50]!;

  /// Base color at 90% lightness.
  Color get shade100 => this[100]!;

  /// Base color at 80% lightness.
  Color get shade200 => this[200]!;

  /// Base color at 70% lightness.
  Color get shade300 => this[300]!;

  /// Base color at 60% lightness.
  Color get shade400 => this[400]!;

  /// Base color at 50% lightness.
  Color get shade500 => this[500]!;

  /// Base color at 40% lightness.
  Color get shade600 => this[600]!;

  /// Base color at 30% lightness.
  Color get shade700 => this[700]!;

  /// Base color at 20% lightness.
  Color get shade800 => this[800]!;

  /// Base color at 10% lightness.
  Color get shade900 => this[900]!;

  /// Darkest shade of the palette, equals: black.
  Color get shade1000 => this[1000]!;

  /// Create a [MaterialColor] out of this palette.
  ///
  /// Note: [shade0], [shade10] and [shade1000] get discarded as they are
  /// not supported in a [MaterialColor].
  MaterialColor get asMaterialColor {
    return MaterialColor(shade500.value, colors);
  }
}
