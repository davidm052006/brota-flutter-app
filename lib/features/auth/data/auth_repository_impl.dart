import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  AppUser? get currentUser => _toAppUser(_supabase.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.map(
      (AuthState state) => _toAppUser(state.session?.user),
    );
  }

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? user = response.user;
      if (user == null) {
        return const ResultError(AuthFailure('No se pudo iniciar sesión.'));
      }
      return Success(_toAppUser(user)!);
    } on AuthException catch (e) {
      return ResultError(_mapAuthException(e));
    } catch (_) {
      return const ResultError(NetworkFailure());
    }
  }

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final User? user = response.user;
      if (user == null) {
        return const ResultError(AuthFailure('No se pudo crear la cuenta.'));
      }
      return Success(_toAppUser(user)!);
    } on AuthException catch (e) {
      return ResultError(_mapAuthException(e));
    } catch (_) {
      return const ResultError(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return const Success(null);
    } on AuthException catch (e) {
      return ResultError(_mapAuthException(e));
    } catch (_) {
      return const ResultError(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return ResultError(_mapAuthException(e));
    } catch (_) {
      return const ResultError(NetworkFailure());
    }
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }

  Failure _mapAuthException(AuthException e) {
    final String message = switch (e.message) {
      'Invalid login credentials' => 'Correo o contraseña incorrectos.',
      _ => e.message,
    };
    return AuthFailure(message);
  }
}
