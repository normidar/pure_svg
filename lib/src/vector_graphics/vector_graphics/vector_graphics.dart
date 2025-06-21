// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:pure_ui/pure_ui.dart' as ui;

import 'listener.dart';
import 'loader.dart';

export 'listener.dart' show PictureInfo;
export 'loader.dart';

/// Utility functionality for interaction with vector graphic assets.
class VectorGraphicUtilities {
  const VectorGraphicUtilities._();

  /// Load the [PictureInfo] from a given [loader].
  ///
  /// It is the caller's responsibility to handle disposing the picture when
  /// they are done with it.
  Future<PictureInfo> loadPicture(BytesLoader loader) async {
    bool clipViewbox = true;
    ui.TextDirection textDirection = ui.TextDirection.ltr;
    ui.Locale locale = ui.PlatformDispatcher.instance.locale;

    return loader.loadBytes().then((ByteData data) {
      try {
        return decodeVectorGraphics(
          data,
          locale: locale,
          textDirection: textDirection,
          loader: loader,
          clipViewbox: clipViewbox,
        );
      } catch (e) {
        print('Failed to decode $loader');
        rethrow;
      }
    });
  }
}

/// The [VectorGraphicUtilities] instance.
const VectorGraphicUtilities vg = VectorGraphicUtilities._();
