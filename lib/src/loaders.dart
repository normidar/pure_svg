import 'dart:typed_data';

import 'package:pure_svg/src/vector_graphics/vector_graphics/loader.dart';
import 'package:pure_svg/src/vector_graphics/vector_graphics_compiler/vector_graphics_compiler.dart'
    as vg;
import 'package:meta/meta.dart';
import 'package:pure_svg/svg.dart';
import 'package:pure_ui/pure_ui.dart';

/// A theme used when decoding an SVG picture.
@immutable
class SvgTheme {
  /// Instantiates an SVG theme with the [currentColor]
  /// and [fontSize].
  ///
  /// Defaults the [fontSize] to 14.
  // WARNING WARNING WARNING
  // If this codebase ever decides to default the font size to something off the
  // BuildContext, caching logic will have to be updated. The font size can
  // temporarily and unexpectedly change during route transitions in common
  // patterns used in `MaterialApp`. This busts caching and destroys
  // performance.
  const SvgTheme({
    this.currentColor = const vg.Color(0xFF000000),
    this.fontSize = 14,
    double? xHeight,
  }) : xHeight = xHeight ?? fontSize / 2;

  /// The default color applied to SVG elements that inherit the color property.
  /// See: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword
  final vg.Color currentColor;

  /// The font size used when calculating em units of SVG elements.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units
  final double fontSize;

  /// The x-height (corpus size) of the font used when calculating ex units of SVG elements.
  /// Defaults to [fontSize] / 2 if not provided.
  /// See: https://www.w3.org/TR/SVG11/coords.html#Units, https://en.wikipedia.org/wiki/X-height
  final double xHeight;

  /// Creates a [vg.SvgTheme] from this.
  vg.SvgTheme toVgTheme() {
    return vg.SvgTheme(
      currentColor: vg.Color.fromARGB(
        ((currentColor.a * 255).round() & 0xff),
        ((currentColor.r * 255).round() & 0xff),
        ((currentColor.g * 255).round() & 0xff),
        ((currentColor.b * 255).round() & 0xff),
      ),
      fontSize: fontSize,
      xHeight: xHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgTheme &&
        currentColor == other.currentColor &&
        fontSize == other.fontSize &&
        xHeight == other.xHeight;
  }

  @override
  int get hashCode => Object.hash(currentColor, fontSize, xHeight);

  @override
  String toString() =>
      'SvgTheme(currentColor: $currentColor, fontSize: $fontSize, xHeight: $xHeight)';
}

/// A class that transforms from one color to another during SVG parsing.
///
/// This object must be immutable so that it is suitable for use in the
/// [svg.cache].
@immutable
abstract class ColorMapper {
  /// Allows const constructors on subclasses.
  const ColorMapper();

  /// Returns a new color to use in place of [color] during SVG parsing.
  ///
  /// The SVG parser will call this method every time it parses a color
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  );
}

/// A [BytesLoader] that parses a SVG data in an isolate and creates a
/// vector_graphics binary representation.
@immutable
abstract class SvgLoader<T> extends BytesLoader {
  /// See class doc.
  const SvgLoader();

  /// Will be called in [compute] with the result of [prepareMessage].
  @protected
  String provideSvg(T? message);

  /// Will be called
  @protected
  Future<T?> prepareMessage() => Future.value(null);

  /// Returns the svg theme.
  // @visibleForTesting
  @protected
  SvgTheme getTheme() {
    return const SvgTheme();
  }

  Future<ByteData> _load() {
    final SvgTheme theme = getTheme();
    return prepareMessage().then((T? message) {
      return vg
          .encodeSvg(
            xml: provideSvg(message),
            theme: theme.toVgTheme(),
            colorMapper: null,
            debugName: 'Svg loader',
            enableClippingOptimizer: false,
            enableMaskingOptimizer: false,
            enableOverdrawOptimizer: false,
          )
          .buffer
          .asByteData();
    });
  }

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<ByteData> loadBytes() {
    return svg.cache.putIfAbsent(cacheKey(), () => _load());
  }

  @override
  SvgCacheKey cacheKey() {
    final SvgTheme theme = getTheme();
    return SvgCacheKey(keyData: this, theme: theme, colorMapper: null);
  }
}

/// A [SvgTheme] aware cache key.
///
/// The theme must be part of the cache key to ensure that otherwise similar
/// SVGs get cached separately.
@immutable
class SvgCacheKey {
  /// See [SvgCacheKey].
  const SvgCacheKey({
    required this.keyData,
    required this.colorMapper,
    this.theme,
  });

  /// The theme for this cached SVG.
  final SvgTheme? theme;

  /// The other key data for the SVG.
  ///
  /// For most loaders, using the loader object itself is suitable.
  final Object keyData;

  /// The color mapper for the SVG, if any.
  final ColorMapper? colorMapper;

  @override
  int get hashCode => Object.hash(theme, keyData, colorMapper);

  @override
  bool operator ==(Object other) {
    return other is SvgCacheKey &&
        other.theme == theme &&
        other.keyData == keyData &&
        other.colorMapper == colorMapper;
  }
}

/// A [BytesLoader] that parses an SVG string in an isolate and creates a
/// vector_graphics binary representation.
class SvgStringLoader extends SvgLoader<void> {
  /// See class doc.
  const SvgStringLoader(this._svg);

  final String _svg;

  @override
  String provideSvg(void message) {
    return _svg;
  }

  @override
  int get hashCode => _svg.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SvgStringLoader && other._svg == _svg;
  }
}
