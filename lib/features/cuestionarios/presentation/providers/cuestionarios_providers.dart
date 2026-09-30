import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/cuestionarios_repository_impl.dart';
import '../../domain/cuestionarios_repository.dart';

final Provider<CuestionariosRepository> cuestionariosRepositoryProvider =
    Provider<CuestionariosRepository>(
      (ref) => CuestionariosRepositoryImpl(ref.watch(dioProvider)),
    );
