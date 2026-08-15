import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a broadcast [Stream] (e.g. Supabase's `onAuthStateChange`)
/// into a [Listenable] so [GoRouter] can re-run its `redirect` callback
/// whenever auth state changes, without polling.
final class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
