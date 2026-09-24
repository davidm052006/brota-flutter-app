import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/programa.dart';
import '../../domain/programas_stats.dart';

part 'programas_state.freezed.dart';

enum ProgramasStatus { idle, loading, loadingMore, error }

/// `loading` es la carga inicial o un refetch por búsqueda/filtro de
/// área (reemplaza [programas]); `loadingMore` es "Cargar más"
/// (concatena). [modalidad] es un filtro client-side puro — no dispara
/// una nueva llamada, solo cambia qué se muestra de [programas].
@freezed
abstract class ProgramasState with _$ProgramasState {
  const factory ProgramasState({
    @Default(ProgramasStatus.idle) ProgramasStatus status,
    @Default([]) List<Programa> programas,
    @Default(0) int total,
    @Default(1) int totalPages,
    @Default(1) int page,
    @Default('') String search,
    String? area,
    String? modalidad,
    ProgramasStats? stats,
    String? errorMessage,
  }) = _ProgramasState;
}
