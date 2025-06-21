// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:meta/meta.dart';

/// An interface that can be implemented to support decoding vector graphic
/// binary assets from different byte sources.
///
/// A bytes loader class should not be constructed directly in a build method,
/// if this is done the corresponding [VectorGraphic] widget may repeatedly
/// reload the bytes.
///
/// Implementations must overide [toString] for debug reporting.
///
/// See also:
///   * [AssetBytesLoader], for loading from the asset bundle.
///   * [NetworkBytesLoader], for loading network bytes.
@immutable
abstract class BytesLoader {
  /// Const constructor to allow subtypes to be const.
  const BytesLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<ByteData> loadBytes();

  /// Create an object that can be used to uniquely identify this asset
  /// and loader combination.
  ///
  /// For most [BytesLoader] subclasses, this can safely return the same
  /// instance. If the loader looks up additional dependencies using the
  /// [context] argument of [loadBytes], then those objects should be
  /// incorporated into a new cache key.
  Object cacheKey() => this;
}
