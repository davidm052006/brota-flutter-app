import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/auth_repository.dart';
import '../providers/auth_providers.dart';
import 'auth_form_state.dart';

final StateNotifierProvider<LoginController, AuthFormState>
loginControllerProvider = StateNotifierProvider<LoginController, AuthFormState>(
  (ref) => LoginController(ref.watch(authRepositoryProvider)),
);

final class LoginController extends StateNotifier<AuthFormState> {
  LoginController(this._authRepository) : super(const AuthFormState());

  final AuthRepository _authRepository;

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(status: AuthFormStatus.loading, errorMessage: null);

    final result = await _authRepository.signInWithEmail(
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
