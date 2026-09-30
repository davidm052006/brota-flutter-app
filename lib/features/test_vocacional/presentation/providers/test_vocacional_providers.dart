import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/test_vocacional_repository_impl.dart';
import '../../domain/test_vocacional_repository.dart';
import '../controllers/test_vocacional_controller.dart';
import '../controllers/test_vocacional_state.dart';

final Provider<TestVocacionalRepository> testVocacionalRepositoryProvider =
    Provider<TestVocacionalRepository>(
      (ref) => TestVocacionalRepositoryImpl(ref.watch(dioProvider)),
    );

final StateNotifierProvider<TestVocacionalController, TestVocacionalState>
testVocacionalControllerProvider =
    StateNotifierProvider<TestVocacionalController, TestVocacionalState>(
      (ref) =>
          TestVocacionalController(ref.watch(testVocacionalRepositoryProvider)),
    );
