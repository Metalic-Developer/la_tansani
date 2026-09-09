class Dhikr {
  final String id;
  final String type;
  final String text;
  final String? reward;
  final int repetitions;
  final int level;
  final int sortOrder;
  final bool active;

  const Dhikr({
    required this.id,
    required this.type,
    required this.text,
    this.reward,
    required this.repetitions,
    required this.level,
    required this.sortOrder,
    required this.active,
  });

  factory Dhikr.fromMap(Map<String, dynamic> map) {
    return Dhikr(
      id: map['id'].toString(),
      type: map['type'].toString(),
      text: map['text'].toString(),
      reward: map['reward'] as String?,
      repetitions: map['repetitions'] as int,
      level: map['level'] as int,
      sortOrder: map['sort_order'] as int,
      active: map['active'] as bool? ?? true,
    );
  }
}
