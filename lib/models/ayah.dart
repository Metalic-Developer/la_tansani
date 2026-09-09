class Ayah {
  final int id;
  final int jozz;
  final int sora;
  final String soraName;
  final int page;
  final int lineStart;
  final int lineEnd;
  final int ayaNo;
  final String ayaText;

  const Ayah({
    required this.id,
    required this.jozz,
    required this.sora,
    required this.soraName,
    required this.page,
    required this.lineStart,
    required this.lineEnd,
    required this.ayaNo,
    required this.ayaText,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      id: map['id'] as int,
      jozz: map['jozz'] as int,
      sora: map['sora'] as int,
      soraName: map['sora_name'] as String,
      page: map['page'] as int,
      lineStart: map['line_start'] as int,
      lineEnd: map['line_end'] as int,
      ayaNo: map['aya_no'] as int,
      ayaText: map['aya_text'] as String,
    );
  }
}
