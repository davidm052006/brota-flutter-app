import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/programas_repository_impl.dart';
import '../../domain/programas_repository.dart';

final Provider<ProgramasRepository> programasRepositoryProvider =
    Provider<ProgramasRepository>(
      (ref) => ProgramasRepositoryImpl(ref.watch(dioProvider)),
    );
