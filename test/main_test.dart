import 'dart:io';

import 'package:pure_svg/src/vector_graphics/vector_graphics/vector_graphics.dart';
import 'package:pure_svg/svg.dart';
import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('PictureRecorder', () {
    test('make a svg image', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 1024, 1024));

      // Read SVG file from same directory
      final svgFile = File('test/test.svg');
      if (!await svgFile.exists()) {
        throw Exception('SVG file not found: ${svgFile.path}');
      }
      final String rawSvg = await svgFile.readAsString();

      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(rawSvg),
      );

      // You can draw the picture to a canvas:
      canvas.drawPicture(pictureInfo.picture);

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);

      // Ensure output directory exists
      final outputDir = Directory('test_output');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Save to file
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/output_image.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      pictureInfo.picture.dispose();
    });
  });
}
