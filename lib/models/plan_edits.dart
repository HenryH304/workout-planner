class SwapRecord {
  final String originalId;
  final String replacementId;

  const SwapRecord({
    required this.originalId,
    required this.replacementId,
  });

  Map<String, dynamic> toJson() {
    return {
      'originalId': originalId,
      'replacementId': replacementId,
    };
  }

  factory SwapRecord.fromJson(Map<String, dynamic> json) {
    return SwapRecord(
      originalId: json['originalId'] as String,
      replacementId: json['replacementId'] as String,
    );
  }
}

class PlanEdits {
  final List<String> added;
  final List<String> removed;
  final List<SwapRecord> swapped;

  const PlanEdits({
    this.added = const [],
    this.removed = const [],
    this.swapped = const [],
  });

  bool get hasEdits =>
      added.isNotEmpty || removed.isNotEmpty || swapped.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'added': added,
      'removed': removed,
      'swapped': swapped.map((s) => s.toJson()).toList(),
    };
  }

  factory PlanEdits.fromJson(Map<String, dynamic> json) {
    return PlanEdits(
      added: List<String>.from(json['added'] as List),
      removed: List<String>.from(json['removed'] as List),
      swapped: (json['swapped'] as List)
          .map((s) => SwapRecord.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }

  PlanEdits copyWith({
    List<String>? added,
    List<String>? removed,
    List<SwapRecord>? swapped,
  }) {
    return PlanEdits(
      added: added ?? this.added,
      removed: removed ?? this.removed,
      swapped: swapped ?? this.swapped,
    );
  }
}
