import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../domain/programas_repository.dart';
import '../providers/programas_providers.dart';
import 'programas_state.dart';

final StateNotifierProvider<ProgramasController, ProgramasState>
programasControllerProvider =
    StateNotifierProvider<ProgramasController, ProgramasState>(
      (ref) => ProgramasController(ref.watch(programasRepositoryProvider)),
    );

/// Búsqueda con debounce de 350ms (0ms si se limpia), "cargar más" que
/// concatena en vez de reemplazar, y filtro de modalidad 100%
/// client-side — ver `FUNCTIONAL_CONTENT_BRIEF.md` sección 2.
final class ProgramasController extends StateNotifier<ProgramasState> {
  ProgramasController(this._repository) : super(const ProgramasState()) {
    loadInitial();
  }

  final ProgramasRepository _repository;
  Timer? _searchDebounce;

  Future<void> loadInitial() async {
    state = state.copyWith(status: ProgramasStatus.loading, errorMessage: null);

    final statsResult = await _repository.getStats();
    statsResult.fold(
      (stats) => state = state.copyWith(stats: stats),
      (_) {}, // los contadores de filtro son secundarios, no bloquean la carga
    );

    await _fetchPage(page: 1, replace: true);
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final Duration delay = query.isEmpty
        ? Duration.zero
        : const Duration(milliseconds: 350);
    _searchDebounce = Timer(delay, () {
      state = state.copyWith(search: query);
      _fetchPage(page: 1, replace: true);
    });
  }

  void onAreaSelected(String? area) {
    state = state.copyWith(area: area);
    _fetchPage(page: 1, replace: true);
  }

  /// Filtro client-side puro — no dispara ninguna llamada.
  void onModalidadSelected(String? modalidad) {
    state = state.copyWith(modalidad: modalidad);
  }

  Future<void> loadMore() async {
    if (state.status == ProgramasStatus.loadingMore) return;
    if (state.page >= state.totalPages) return;
    await _fetchPage(page: state.page + 1, replace: false);
  }

  Future<void> _fetchPage({required int page, required bool replace}) async {
    state = state.copyWith(
      status: replace ? ProgramasStatus.loading : ProgramasStatus.loadingMore,
      errorMessage: null,
    );

    final result = await _repository.getProgramas(
      area: state.area,
      search: state.search,
      page: page,
    );

    state = result.fold(
      (programasPage) => state.copyWith(
        status: ProgramasStatus.idle,
        programas: replace
            ? programasPage.data
            : [...state.programas, ...programasPage.data],
        total: programasPage.total,
        totalPages: programasPage.totalPages,
        page: page,
      ),
      (failure) => state.copyWith(
        status: ProgramasStatus.error,
        errorMessage: failure.message,
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
