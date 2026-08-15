import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_form_state.freezed.dart';

enum AuthFormStatus { idle, loading, success, error }

/// Shared submission state for the login, registro, and
/// "olvidé mi contraseña" forms — all three are "call one auth
/// endpoint, show a spinner, surface a Failure" and don't need three
/// near-identical state classes.
@freezed
abstract class AuthFormState with _$AuthFormState {
  const factory AuthFormState({
    @Default(AuthFormStatus.idle) AuthFormStatus status,
    String? errorMessage,
  }) = _AuthFormState;
}
