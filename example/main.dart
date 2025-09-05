import 'dart:io';
import 'dart:math' as math;

import 'package:pure_ui/pure_ui.dart' as ui;
import 'package:test/test.dart';

void main() {
  group('PictureRecorder', () {
    test('make a svg image', () async {
      final recorder = ui.PictureRecorder();
      final canvas =
          ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 400, 400));

      // Background gradient effect (simulated with multiple rectangles)
      for (int i = 0; i < 400; i += 10) {
        final opacity = (255 - (i * 255 / 400)).round();
        final paint = ui.Paint()
          ..color = ui.Color.fromARGB(opacity, 100, 150, 255)
          ..style = ui.PaintingStyle.fill;
        canvas.drawRect(ui.Rect.fromLTWH(i.toDouble(), 0, 10, 400), paint);
      }

      // Draw overlapping circles with different colors
      final colors = [
        const ui.Color(0xFFFF0000), // Red
        const ui.Color(0xFF00FF00), // Green
        const ui.Color(0xFF0000FF), // Blue
        const ui.Color(0xFFFFFF00), // Yellow
        const ui.Color(0xFFFF00FF), // Magenta
      ];

      for (int i = 0; i < colors.length; i++) {
        final paint = ui.Paint()
          ..color = colors[i].withValues(alpha: 0.7)
          ..style = ui.PaintingStyle.fill;

        final centerX = 100 + (i * 50).toDouble();
        final centerY = 200.0;
        canvas.drawCircle(ui.Offset(centerX, centerY), 60, paint);
      }

      // Draw concentric rectangles with rotation
      canvas.save();
      canvas.translate(200, 200);
      for (int i = 0; i < 5; i++) {
        canvas.save();
        canvas.rotate(i * math.pi / 8);

        final paint = ui.Paint()
          ..color =
              ui.Color.fromARGB(255, 255 - (i * 40), i * 40, 100 + (i * 30))
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3.0;

        final size = 80 - (i * 10).toDouble();
        canvas.drawRect(
            ui.Rect.fromCenter(
                center: ui.Offset.zero, width: size, height: size),
            paint);
        canvas.restore();
      }
      canvas.restore();

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);

      expect(image.width, 400);
      expect(image.height, 400);

      // Save as PNG for visual verification
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('test_output/complex_geometric.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('Complex geometric shapes saved: ${file.path}');
    });
  });
}
