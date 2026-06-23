import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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

  group('svg.toPng size scaling', () {
    Future<ui.Image> decodePng(Uint8List png) {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(png, completer.complete);
      return completer.future;
    }

    Future<ui.Color> pixelAt(ui.Image image, int x, int y) async {
      final ByteData rgba =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final int i = (y * image.width + x) * 4;
      return ui.Color.fromARGB(
        rgba.getUint8(i + 3),
        rgba.getUint8(i),
        rgba.getUint8(i + 1),
        rgba.getUint8(i + 2),
      );
    }

    test('scales content to fill a larger target size', () async {
      // A 24x24 viewBox fully covered in red.
      const String svgString =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect width="24" height="24" fill="#ff0000"/>'
          '</svg>';

      final Uint8List png = await svg.toPng(
        SvgStringLoader(svgString),
        width: 1024,
        height: 1024,
      );
      final ui.Image image = await decodePng(png);

      expect(image.width, 1024);
      expect(image.height, 1024);
      // Without scaling, only the top-left 24x24 corner would be red and
      // everywhere else (e.g. the center) would be transparent.
      expect(await pixelAt(image, 512, 512), const ui.Color(0xFFFF0000));
      expect(await pixelAt(image, 1000, 1000), const ui.Color(0xFFFF0000));
    });

    test('letterboxes content that does not match the target aspect ratio',
        () async {
      // A 12x12 red square centered in a 24x24 viewBox.
      const String svgString =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="6" y="6" width="12" height="12" fill="#ff0000"/>'
          '</svg>';

      final Uint8List png = await svg.toPng(
        SvgStringLoader(svgString),
        width: 2048,
        height: 512,
      );
      final ui.Image image = await decodePng(png);

      // Contain-fit scale is 512/24; drawn content is centered horizontally,
      // so the far left/right edges stay transparent while the center
      // (where the square now is) is red.
      expect(await pixelAt(image, 1024, 256), const ui.Color(0xFFFF0000));
      expect(await pixelAt(image, 10, 10), isNot(const ui.Color(0xFFFF0000)));
      expect(
        await pixelAt(image, 2030, 10),
        isNot(const ui.Color(0xFFFF0000)),
      );
    });
  });
}
