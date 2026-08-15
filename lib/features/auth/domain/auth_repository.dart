import '../../../core/result/result.dart';
import 'app_user.dart';

/// Contract for authentication, backed by Supabase Auth — the same
/// identity provider `backend/src/middlewares/verificarAuth.js` trusts.
/// The presentation layer only ever depends on this interface, never on
/// `supabase_flutter` directly.
abstract class AuthRepository {
  AppUser? get currentUser;

  /// Emits the current user on every sign-in/sign-out/token-refresh.
  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
