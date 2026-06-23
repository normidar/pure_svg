import 'dart:typed_data';

import 'package:pure_svg/src/vector_graphics/vector_graphics/vector_graphics.dart';
import 'package:pure_ui/pure_ui.dart' as ui;

/// Renders a vector graphic loaded by [loader] directly to PNG bytes.
///
/// This hides the [ui.Canvas]/[ui.Image] steps (and therefore the need to
/// `import 'package:pure_ui/pure_ui.dart'`) for callers who only need a PNG.
///
/// If [width] or [height] are omitted, the intrinsic size reported by the
/// decoded picture ([PictureInfo.size]) is used.
Future<Uint8List> renderSvgToPng(
  BytesLoader loader, {
  int? width,
  int? height,
}) async {
  final PictureInfo pictureInfo = await vg.loadPicture(loader);
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
