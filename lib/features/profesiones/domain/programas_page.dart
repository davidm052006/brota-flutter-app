import 'programa.dart';

/// Una página de resultados de `GET /api/programas` — paginado real,
/// no todo el catálogo (~14.644 programas del MEN).
final class ProgramasPage {
  const ProgramasPage({
    required this.data,
    required this.total,
    required this.totalPages,
  });

  factory ProgramasPage.fromJson(Map<String, dynamic> json) {
    return ProgramasPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => Programa.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  final List<Programa> data;
  final int total;
  final int totalPages;
}
