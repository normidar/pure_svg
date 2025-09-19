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

      // Load SVG from file
      final file = File('test/icon.svg');
      final svgString = await file.readAsString();

      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
      );

      // Draw the picture to the canvas:
      canvas.drawPicture(pictureInfo.picture);

      // Convert the canvas recording to an image:
      final picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(1024, 1024);

      // Export image as PNG
      final pngData = await image.toByteData(format: ui.ImageByteFormat.png);

      // Save to file
      final outputFile = File('test_output/output_image.png');
      await outputFile.writeAsBytes(pngData!.buffer.asUint8List());

      pictureInfo.picture.dispose();
      picture.dispose();
    });
  });
}
