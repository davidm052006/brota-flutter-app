import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/continue_section.dart';
import '../widgets/hero_banner.dart';
import '../widgets/quick_actions.dart';

/// `/dashboard` — Inicio. Ver `frontend/src/pages/dashboard/
/// Dashboard.jsx`: HeroBanner → QuickActions → ContinueSection.
///
/// La columna derecha del desktop (`ProfileSidebar` con racha y
/// completitud de perfil) no aplica en mobile por falta de espacio — ver
/// `MOBILE_DESIGN_BRIEF.md` sección 2.2.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? email = ref.watch(authStateChangesProvider).value?.email;
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brota'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            HeroBanner(userEmail: email),
            const SizedBox(height: AppSpacing.xl),
            const QuickActions(),
            const SizedBox(height: AppSpacing.xl),
            const ContinueSection(),
          ],
        ),
      ),
    );
  }
}
