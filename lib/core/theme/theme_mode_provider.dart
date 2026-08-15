import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current [ThemeMode] for the app. Defaults to [ThemeMode.system] so the
/// app follows the OS setting until the user overrides it from the UI.
final StateProvider<ThemeMode> themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.system,
);
