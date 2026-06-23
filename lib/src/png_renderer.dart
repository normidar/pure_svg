import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pure_svg/src/loaders.dart';
import 'package:pure_svg/src/vector_graphics/vector_graphics/vector_graphics.dart';
import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:xml/xml.dart';

/// Renders a vector graphic loaded by [loader] directly to PNG bytes.
///
/// This hides the [ui.Canvas]/[ui.Image] steps (and therefore the need to
/// `import 'package:pure_ui/pure_ui.dart'`) for callers who only need a PNG.
///
/// If [width] or [height] are omitted, the intrinsic size reported by the
/// decoded picture ([PictureInfo.size]) is used.
///
/// If both are given and the SVG's intrinsic aspect ratio differs, the
/// content is scaled to fit inside the requested size (like `BoxFit.contain`)
/// and centered, instead of being clipped to the top-left corner of the
/// canvas.
Future<Uint8List> renderSvgToPng(
  BytesLoader loader, {
  int? width,
  int? height,
}) async {
  BytesLoader effectiveLoader = loader;
  if ((width != null || height != null) && loader is SvgLoader) {
    final String svgSource = await loader.resolveSvgSource();
    final String? scaledSvg = _scaleSvgToFit(
      svgSource,
      width: width,
      height: height,
    );
    if (scaledSvg != null) {
      effectiveLoader = SvgStringLoader(scaledSvg);
    }
  }

  final PictureInfo pictureInfo = await vg.loadPicture(effectiveLoader);
  try {
    final int targetWidth = width ?? pictureInfo.size.width.round();
    final int targetHeight = height ?? pictureInfo.size.height.round();
    final ui.Image image = await pictureInfo.picture.toImage(
      targetWidth,
      targetHeight,
    );
    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    pictureInfo.picture.dispose();
  }
}

/// Rewrites [svgSource] so its content is scaled (preserving aspect ratio,
/// like `BoxFit.contain`) and centered to fill a [width]x[height] viewBox.
///
/// This bakes the scale/translate directly into the SVG (via a wrapping
/// `<g transform="...">`) rather than relying on a transform applied to the
/// decoded [Picture] at draw time, since the vector graphics compiler bakes
/// `<g transform>` into the actual path coordinates at parse time, while a
/// runtime `Canvas.scale`/`translate` is not honored by `Picture.toImage`.
///
/// Returns null if [svgSource] has no root `<svg>` element or no usable
/// `viewBox`/`width`/`height` to compute a scale from, in which case the
/// caller should fall back to the unscaled SVG.
String? _scaleSvgToFit(String svgSource, {int? width, int? height}) {
  final XmlDocument document = XmlDocument.parse(svgSource);
  final XmlElement? root =
      document.rootElement.name.local == 'svg' ? document.rootElement : null;
  if (root == null) {
    return null;
  }

  double minX = 0;
  double minY = 0;
  double sourceWidth;
  double sourceHeight;
  final String? viewBox = root.getAttribute('viewBox');
  if (viewBox != null && viewBox.trim().isNotEmpty) {
    final List<double?> parts =
        viewBox.trim().split(RegExp(r'[\s,]+')).map(double.tryParse).toList();
    if (parts.length != 4 || parts.any((double? e) => e == null)) {
      return null;
    }
    minX = parts[0]!;
    minY = parts[1]!;
    sourceWidth = parts[2]!;
    sourceHeight = parts[3]!;
  } else {
    final double? rawWidth = _parseLength(root.getAttribute('width'));
    final double? rawHeight = _parseLength(root.getAttribute('height'));
    if (rawWidth == null || rawHeight == null) {
      return null;
    }
    sourceWidth = rawWidth;
    sourceHeight = rawHeight;
  }
  if (sourceWidth <= 0 || sourceHeight <= 0) {
    return null;
  }

  final double targetWidth = (width ?? sourceWidth.round()).toDouble();
  final double targetHeight = (height ?? sourceHeight.round()).toDouble();
  final double scale = math.min(
    targetWidth / sourceWidth,
    targetHeight / sourceHeight,
  );
  final double offsetX = (targetWidth - sourceWidth * scale) / 2;
  final double offsetY = (targetHeight - sourceHeight * scale) / 2;
  final double translateX = offsetX - minX * scale;
  final double translateY = offsetY - minY * scale;

  final List<XmlNode> children =
      root.children.map((XmlNode node) => node.copy()).toList();
  root.children.clear();
  root.children.add(
    XmlElement(
      XmlName('g'),
      <XmlAttribute>[
        XmlAttribute(
          XmlName('transform'),
          'translate($translateX, $translateY) scale($scale)',
        ),
      ],
      children,
    ),
  );
  root.setAttribute('viewBox', '0 0 $targetWidth $targetHeight');
  root.setAttribute('width', '$targetWidth');
  root.setAttribute('height', '$targetHeight');

  return document.toXmlString();
}

/// Parses a raw SVG length attribute (e.g. `"24"`, `"24px"`) into pixels.
///
/// Returns null for unsupported units (e.g. percentages) since there is no
/// absolute pixel size to scale against.
double? _parseLength(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final String trimmed = raw.trim();
  final String numericPart = trimmed.endsWith('px')
      ? trimmed.substring(0, trimmed.length - 2)
      : trimmed;
  return double.tryParse(numericPart);
}
