/// The authenticated user as far as the rest of the app needs to know —
/// deliberately thin. Anything richer (nombre, rol, avatar) lives in
/// `perfiles_usuario` and belongs to the `perfil` feature, fetched
/// separately once a session exists.
final class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;
}
