import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/brota_app.dart';
import 'core/env/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppEnv.load();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: BrotaApp()));
}
