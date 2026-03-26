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

    test('make a svg image with text', () async {
      // Load system fonts (Arial Unicode supports full Unicode including Japanese)
      ui.FontLoader.loadFromFile(
        'serif',
        '/System/Library/Fonts/NewYork.ttf',
      );
      ui.FontLoader.loadFromFile(
        'sans-serif',
        '/System/Library/Fonts/SFNS.ttf',
      );
      ui.FontLoader.loadFromFile(
        'ArialUnicode',
        '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
      );

      const svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="400">
  <rect width="800" height="400" fill="#f5f5f5"/>
  <text x="400" y="80" font-family="serif" font-size="48" font-weight="bold"
        text-anchor="middle" fill="#333333">Hello, SVG!</text>
  <text x="400" y="160" font-family="sans-serif" font-size="36"
        text-anchor="middle" fill="#0066cc">Text Rendering Test</text>
  <text x="400" y="260" font-family="ArialUnicode" font-size="40"
        text-anchor="middle" fill="#cc3300">日本語テキスト描画</text>
  <text x="400" y="340" font-family="ArialUnicode" font-size="28"
        text-anchor="middle" fill="#006633">SVGに文字を入れるテスト</text>
</svg>''';

      final PictureInfo pictureInfo = await vg.loadPicture(
        SvgStringLoader(svgString),
      );

      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 800, 400));
      canvas.drawPicture(pictureInfo.picture);

      final picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(800, 400);
      final pngData = await image.toByteData(format: ui.ImageByteFormat.png);

      final outputFile = File('test_output/output_text.png');
      await outputFile.writeAsBytes(pngData!.buffer.asUint8List());

      pictureInfo.picture.dispose();
      picture.dispose();
      ui.FontLoader.clear();
    });
  });
}
