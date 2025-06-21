import 'package:pure_svg/svg.dart';

import 'src/cache.dart';

export 'src/cache.dart';
export 'src/loaders.dart';

/// Instance for [Svg]'s utility methods, which can produce a [DrawableRoot]
/// or [PictureInfo] from [String] or [Uint8List].
final Svg svg = Svg._();

/// A utility class for decoding SVG data to a [DrawableRoot] or a [PictureInfo].
///
/// These methods are used by [SvgPicture], but can also be directly used e.g.
/// to create a [DrawableRoot] you manipulate or render to your own [Canvas].
/// Access to this class is provided by the exported [svg] member.
class Svg {
  Svg._();

  /// A global override flag for [SvgPicture.cacheColorFilter].
  ///
  /// If this is null, the value in [SvgPicture.cacheColorFilter] is used. If it
  /// is not null, it will override that value.
  @Deprecated('This no longer does anything.')
  bool? cacheColorFilterOverride;

  /// The cache instance for decoded SVGs.
  final Cache cache = Cache();
}

// ignore: avoid_classes_with_only_static_members
/// Deprecated class, will be removed, does not do anything.
@Deprecated('This feature does not do anything anymore.')
class PictureProvider {
  /// Deprecated, use [svg.cache] instead.
  @Deprecated('Use svg.cache instead.')
  static Cache get cache => svg.cache;
}
