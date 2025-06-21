import 'package:pure_svg/src/vector_graphics/vector_graphics/vector_graphics.dart';
import 'package:pure_svg/svg.dart';
import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('PictureRecorder', () {
    test('初期状態では記録中である', () async {
      final canvas = ui.Canvas.forRecording();

      const String rawSvg =
          '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="lg" x1="100%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ffcf68"/>
      <stop offset="100%" stop-color="#e0903b"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="1024" height="1024" fill="url(#lg)" />
  <g transform="translate(6,6) scale(30)">
    <path d="M3 6h19 M3 11.5h16 M3 17h11" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round" />
    <circle cx="20" cy="17" r="2.5" fill="#FFD700" />
  </g>
</svg>
''';
      final PictureInfo pictureInfo =
          await vg.loadPicture(const SvgStringLoader(rawSvg));

      // You can draw the picture to a canvas:
      canvas.drawPicture(pictureInfo.picture);

      // Or convert the picture to an image:
      final ui.Image image = await pictureInfo.picture.toImage(1024, 1024);

      // 画像をPNGとしてエクスポート
      final pngData = image.toPng();

      // ファイルに保存
      final file = File('test_output/output_image.png');
      await file.writeAsBytes(pngData);

      pictureInfo.picture.dispose();
    });
  });
}
