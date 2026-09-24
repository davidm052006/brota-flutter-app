/// Conteos por área académica, para los contadores de los filtros — ver
/// `GET /api/programas/stats` en `FUNCTIONAL_CONTENT_BRIEF.md` sección 2.
final class ProgramasStats {
  const ProgramasStats({required this.total, required this.areas});

  factory ProgramasStats.fromJson(Map<String, dynamic> json) {
    return ProgramasStats(
      total: json['total'] as int? ?? 0,
      areas: (json['areas'] as List<dynamic>)
          .map((e) => AreaCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int total;
  final List<AreaCount> areas;
}

final class AreaCount {
  const AreaCount({required this.area, required this.count});

  factory AreaCount.fromJson(Map<String, dynamic> json) {
    return AreaCount(
      area: json['area'] as String,
      count: json['count'] as int? ?? 0,
    );
  }

  final String area;
  final int count;
}
