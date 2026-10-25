import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// A place in the app a link can open.
sealed class DeepLink {
  const DeepLink();

  /// The shareable https form. Opens the app where Android has verified the
  /// domain (see docs/DEEP_LINKS.md); the `clarion://` form always does.
  Uri get uri;

  static const String host = 'clarion-e08f0.web.app';
  static const String scheme = 'clarion';

  /// Reads both forms:
  ///  * `https://clarion-e08f0.web.app/p/<id>`, `/orders/<id>`,
  ///    `/browse?category=Audio`
  ///  * `clarion://product/<id>`, `clarion://orders/<id>`,
  ///    `clarion://browse?category=Audio`
  ///
  /// Anything else, including an unknown path, is `null`. Ids are not
  /// trusted here: the shell checks them against the catalogue and order
  /// history before opening anything.
  static DeepLink? parse(Uri uri) {
    final List<String> path;
    if (uri.scheme == scheme) {
      path = [uri.host, ...uri.pathSegments];
    } else if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == host) {
      path = uri.pathSegments;
    } else {
      return null;
    }
    final segments = path.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    final id = segments.length == 2 ? segments[1] : null;
    return switch (segments.first) {
      'p' || 'product' when id != null => ProductLink(id),
      'orders' when id != null => OrderLink(id),
      'browse' when segments.length == 1 => BrowseLink(
        uri.queryParameters['category'],
      ),
      _ => null,
    };
  }
}

final class ProductLink extends DeepLink {
  const ProductLink(this.productId);
  final String productId;

  @override
  Uri get uri => Uri.https(DeepLink.host, '/p/$productId');

  @override
  bool operator ==(Object other) =>
      other is ProductLink && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}

final class OrderLink extends DeepLink {
  const OrderLink(this.orderId);
  final String orderId;

  @override
  Uri get uri => Uri.https(DeepLink.host, '/orders/$orderId');

  @override
  bool operator ==(Object other) =>
      other is OrderLink && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

final class BrowseLink extends DeepLink {
  const BrowseLink([this.category]);
  final String? category;

  @override
  Uri get uri => Uri.https(DeepLink.host, '/browse', {
    if (category != null) 'category': category,
  });

  @override
  bool operator ==(Object other) =>
      other is BrowseLink && other.category == category;

  @override
  int get hashCode => category.hashCode;
}

/// Incoming links and notification taps, held until the signed-in shell is
/// ready to open them. A link that arrives before sign-in waits here and is
/// opened once the account's app is up.
abstract final class DeepLinks {
  /// The next place to open, until the shell consumes it.
  static final ValueNotifier<DeepLink?> pending = ValueNotifier(null);

  static StreamSubscription<Uri>? _subscription;

  /// Call once before `runApp`. Android only for now; elsewhere a no-op.
  static void init() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      // The stream also delivers the link that launched the app.
      _subscription ??= AppLinks().uriLinkStream.listen(
        open,
        onError: (Object error) =>
            developer.log('Deep link error', error: error),
      );
    } catch (error, stack) {
      developer.log('Deep links unavailable', error: error, stackTrace: stack);
    }
  }

  /// Queues [uri] if Clarion understands it.
  static void open(Uri uri) {
    final link = DeepLink.parse(uri);
    if (link != null) pending.value = link;
  }
}
