## 0.2.0

- Fix `svg.toPng()` (and `renderSvgToPng()`) ignoring the requested `width`/`height` when they didn't match the SVG's intrinsic size: content was previously rendered unscaled into the top-left corner of the output canvas instead of being scaled to fill it. Content is now scaled to fit (preserving aspect ratio, like `BoxFit.contain`) and centered.

## 0.1.0

- Add `svg.toPng()` to render an SVG directly to PNG bytes without needing to `import 'package:pure_ui/pure_ui.dart'`.
- Fix README example using non-existent `Image.toPng()`; use `Image.toByteData(format: ImageByteFormat.png)` instead.

## 0.0.6

- Fix gradient rendering issues.

## 0.0.5

- Update pure_ui dependency to 0.1.1.

## 0.0.4

- Format dart code.
- Change dependencies lower bounds.

## 0.0.3

- Add topics on pub.dev.

## 0.0.2

- Refactoring project to get more pub points.

## 0.0.1

- Fork from pure_svg and make it pure.
