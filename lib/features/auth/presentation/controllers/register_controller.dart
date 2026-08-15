import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/auth_repository.dart';
import '../providers/auth_providers.dart';
import 'auth_form_state.dart';

final StateNotifierProvider<RegisterController, AuthFormState>
registerControllerProvider =
    StateNotifierProvider<RegisterController, AuthFormState>(
      (ref) => RegisterController(ref.watch(authRepositoryProvider)),
    );

// TODO(perfil-feature): once `features/perfil` exists, chain a call to
// `POST /api/auth/register-perfil` after a successful signUp — that's
// what creates the `perfiles_usuario` row on the backend
// (see backend/src/controllers/authController.js). Until then this only
// creates the Supabase auth.users record.
final class RegisterController extends StateNotifier<AuthFormState> {
  RegisterController(this._authRepository) : super(const AuthFormState());

  final AuthRepository _authRepository;

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(status: AuthFormStatus.loading, errorMessage: null);

    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
    );

    state = result.fold(
      (_) => state.copyWith(status: AuthFormStatus.success),
      (failure) => state.copyWith(
        status: AuthFormStatus.error,
        errorMessage: failure.message,
      ),
    );
  }
}
