import 'dart:convert';

/// Shared model for rock prediction items used across serializers.
class RockItem {
  final double lengthMm;
  final List<int> bbox;
  final bool isAboveThreshold;

  RockItem({required this.lengthMm, required this.bbox, required this.isAboveThreshold});

  factory RockItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['bbox'] as List<dynamic>? ?? [];
    final bbox = raw.map((e) => (e as num).toInt()).toList();
    return RockItem(
      lengthMm: (json['length_mm'] ?? 0.0).toDouble(),
      bbox: bbox,
      isAboveThreshold: json['is_above_threshold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'length_mm': lengthMm,
        'bbox': bbox,
        'is_above_threshold': isAboveThreshold,
      };

  @override
  String toString() => jsonEncode(toJson());
}
