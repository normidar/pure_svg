# pure_svg

[![Pub](https://img.shields.io/pub/v/pure_svg.svg)](https://pub.dartlang.org/packages/pure_svg)

A library for rendering SVG files without Flutter dependencies.

## Overview

This library is a fork of [flutter_svg](https://pub.dev/packages/flutter_svg) that removes Flutter dependencies and replaces `dart:ui` with [pure_ui](https://pub.dev/packages/pure_ui). This enables SVG rendering outside of Flutter environments.

### Key Changes

- **Flutter Dependencies Removed**: Operates as pure Dart code without Flutter Widget system
- **dart:ui → pure_ui**: Replaces Flutter's UI drawing functionality with the `pure_ui` package
- **Standalone Execution**: Enables SVG rendering and image conversion without Flutter environment

## Installation

```yaml
dependencies:
  pure_svg: ^latest_version
```

## Basic Usage

### Generate Image from SVG String

```dart
import 'package:pure_svg/src/vector_graphics/vector_graphics/vector_graphics.dart';
import 'package:pure_svg/svg.dart';
import 'package:pure_ui/pure_ui.dart' as ui;

const String rawSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="50" height="50" fill="#FF0000" />
  <circle cx="75" cy="75" r="25" fill="#00FF00" />
</svg>
''';

// Load SVG
final PictureInfo pictureInfo = 
    await vg.loadPicture(const SvgStringLoader(rawSvg));

// Draw to canvas
final canvas = ui.Canvas.forRecording();
canvas.drawPicture(pictureInfo.picture);

// Convert to image
final ui.Image image = await pictureInfo.picture.toImage(100, 100);

// Export as PNG data
final pngData = image.toPng();

// Dispose resources
pictureInfo.picture.dispose();
```

### Generate Image from File

```dart
import 'dart:io';

// Load SVG file
final svgString = await File('path/to/your.svg').readAsString();
final PictureInfo pictureInfo = 
    await vg.loadPicture(SvgStringLoader(svgString));

// Convert to image
final ui.Image image = await pictureInfo.picture.toImage(512, 512);

// Save to file
final pngData = image.toPng();
await File('output.png').writeAsBytes(pngData);

pictureInfo.picture.dispose();
```

## Advanced Features

### Color Mapping

You can dynamically change SVG colors:

```dart
class _MyColorMapper extends ColorMapper {
  const _MyColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFFFF0000)) {
      return Colors.blue;
    }
    if (color == const Color(0xFF00FF00)) {
      return Colors.yellow;
    }
    return color;
  }
}

// Load SVG with color mapping applied
final PictureInfo pictureInfo = await vg.loadPicture(
  SvgStringLoader(rawSvg),
  null, // context
  colorMapper: const _MyColorMapper(),
);
```

## SVG Optimization and Precompilation

The vector_graphics backend supports SVG compilation which produces a binary format that is faster to parse and can optimize SVGs to reduce the amount of clipping, masking, and overdraw.

```sh
dart run vector_graphics_compiler -i assets/foo.svg -o assets/foo.svg.vec
```

Loading precompiled files:

```dart
import 'package:vector_graphics/vector_graphics.dart';

const Widget svg = SvgPicture(AssetBytesLoader('assets/foo.svg.vec'));
```

## SVG Compatibility Check

To test SVG compatibility with the vector_graphics backend:

```sh
dart run vector_graphics_compiler -i $SVG_FILE -o $TEMPORARY_OUTPUT_TO_BE_DELETED --no-optimize-masks --no-optimize-clips --no-optimize-overdraw --no-tessellate
```

## Recommended Adobe Illustrator SVG Configuration

- **Styling**: Choose Presentation Attributes instead of Inline CSS because CSS is not fully supported
- **Images**: Choose Embed not Linked to other files to get a single SVG with no dependency on other files
- **Object IDs**: Choose layer names to add every layer name to SVG tags (optional)

![Export configuration](https://user-images.githubusercontent.com/2842459/62599914-91de9c00-b8fe-11e9-8fb7-4af57d5100f7.png)

## SVG Sample Attribution

SVGs in `/assets/w3samples` pulled from [W3 sample files](https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/)

SVGs in `/assets/deborah_ufw` provided by @deborah-ufw

SVGs in `/assets/simple` are pulled from trivial examples or generated to test
basic functionality - some of them come directly from the SVG 1.1 spec. Some
have also come or been adapted from issues raised in this repository.

SVGs in `/assets/wikimedia` are pulled from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page)

Android Drawables in `/assets/android_vd` are pulled from Android Documentation
and examples.

The Flutter Logo created based on the Flutter Logo Widget © Google.

The Dart logo is from
[dartlang.org](https://github.com/dart-lang/site-shared/blob/master/src/_assets/images/dart/logo%2Btext/horizontal/original.svg)
© Google

SVGs in `/assets/noto-emoji` are from [Google i18n noto-emoji](https://github.com/googlei18n/noto-emoji),
licensed under the Apache license.

Please submit SVGs that can't render properly (e.g. that don't render here the
way they do in chrome), as long as they're not using anything "probably out of
scope" (above).

## Acknowledgment

This package was originally authored by
[Dan Field](https://github.com/dnfield) and has been forked here
from [dnfield/pure_svg](https://github.com/dnfield/pure_svg).
Dan was a member of the Flutter team at Google from 2018 until his death
in 2024. Dan’s impact and contributions to Flutter were immeasurable.
