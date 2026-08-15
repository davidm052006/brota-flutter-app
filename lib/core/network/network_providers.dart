import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dio_client.dart';

/// Shared infra providers — every feature reads the Supabase/Dio clients
/// from here instead of touching `Supabase.instance` directly, so tests
/// can override them with fakes.
final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final Provider<Dio> dioProvider = Provider<Dio>(
  (ref) => buildDioClient(ref.watch(supabaseClientProvider)),
);
