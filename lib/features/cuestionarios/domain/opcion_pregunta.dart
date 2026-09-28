final class OpcionPregunta {
  const OpcionPregunta({
    this.id,
    required this.label,
    this.icon,
    required this.orden,
    this.pesos = const {},
  });

  factory OpcionPregunta.fromJson(Map<String, dynamic> json) {
    final Object? rawWeights = json['pesos'];
    final Map<String, int> weights = {};
    if (rawWeights is Map) {
      for (final MapEntry<Object?, Object?> entry in rawWeights.entries) {
        final Object? value = entry.value;
        if (entry.key is String && value is num) {
          weights[entry.key! as String] = value.toInt();
        } else if (entry.key is String) {
          final int? parsed = int.tryParse(value.toString());
          if (parsed != null) weights[entry.key! as String] = parsed;
        }
      }
    }

    return OpcionPregunta(
      id: json['id'] as String?,
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
      orden: _asInt(json['orden']),
      pesos: weights,
    );
  }

  final String? id;
  final String label;
  final String? icon;
  final int orden;
  final Map<String, int> pesos;

  Map<String, dynamic> toApi() => {
    'label': label,
    'icon': icon,
    'orden': orden,
    'pesos': pesos,
  };
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
