import 'dart:convert';

class PanicRecord {
  const PanicRecord({
    required this.id,
    required this.createdAt,
    required this.moodEmoji,
    required this.entry,
    required this.panicOccurred,
    this.panicOccurredAt,
    this.panicContext,
    this.panicSymptoms = const [],
  });

  factory PanicRecord.fromJson(Map<String, dynamic> json) {
    return PanicRecord(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      moodEmoji: json['moodEmoji'] as String,
      entry: json['entry'] as String?,
      panicOccurred: json['panicOccurred'] as bool,
      panicOccurredAt: json['panicOccurredAt'] == null
          ? null
          : DateTime.parse(json['panicOccurredAt'] as String),
      panicContext: json['panicContext'] as String?,
      panicSymptoms: (json['panicSymptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );
  }

  factory PanicRecord.fromJsonString(String source) {
    return PanicRecord.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  final String id;
  final DateTime createdAt;
  final String moodEmoji;
  final String? entry;
  final bool panicOccurred;
  final DateTime? panicOccurredAt;
  final String? panicContext;
  final List<String> panicSymptoms;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'moodEmoji': moodEmoji,
      'entry': entry,
      'panicOccurred': panicOccurred,
      'panicOccurredAt': panicOccurredAt?.toIso8601String(),
      'panicContext': panicContext,
      'panicSymptoms': panicSymptoms,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  PanicRecord copyWith({
    String? id,
    DateTime? createdAt,
    String? moodEmoji,
    String? entry,
    bool? panicOccurred,
    DateTime? panicOccurredAt,
    String? panicContext,
    List<String>? panicSymptoms,
  }) {
    return PanicRecord(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      entry: entry ?? this.entry,
      panicOccurred: panicOccurred ?? this.panicOccurred,
      panicOccurredAt: panicOccurredAt ?? this.panicOccurredAt,
      panicContext: panicContext ?? this.panicContext,
      panicSymptoms: panicSymptoms ?? this.panicSymptoms,
    );
  }
}
