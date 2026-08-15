import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/app_user.dart';
import '../../domain/auth_repository.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(ref.watch(supabaseClientProvider)),
    );

/// Emits whenever the Supabase session changes (sign-in, sign-out,
/// token refresh). [AppRouter] listens to this to gate `/dashboard`.
final StreamProvider<AppUser?> authStateChangesProvider =
    StreamProvider<AppUser?>(
      (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
    );
