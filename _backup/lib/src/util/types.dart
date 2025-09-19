
enum ScenarioType { sliding, wtf }

class Scenario {
  final String shortText;
  final String longText;
  final int probability; // 0..100
  final String rationale;
  final int likes;
  Scenario({required this.shortText, required this.longText, required this.probability, required this.rationale, this.likes = 0});
  Scenario copyWith({String? shortText, String? longText, int? probability, String? rationale, int? likes}) =>
      Scenario(shortText: shortText ?? this.shortText, longText: longText ?? this.longText, probability: probability ?? this.probability, rationale: rationale ?? this.rationale, likes: likes ?? this.likes);
  Map<String, dynamic> toJson() => {'short': shortText, 'long': longText, 'prob': probability, 'why': rationale, 'likes': likes};
  factory Scenario.fromJson(Map<String, dynamic> j) => Scenario(shortText: j['short']??'', longText: j['long']??'', probability: (j['prob']??0).toInt(), rationale: j['why']??'', likes: (j['likes']??0).toInt());
}

class WhatfEntry {
  final String id;
  final String question;
  final bool isFuture;
  final String createdAt;
  Scenario sliding;
  Scenario wtf;
  WhatfEntry({required this.id, required this.question, required this.isFuture, required this.createdAt, required this.sliding, required this.wtf});
  Map<String, dynamic> toJson() => {'id': id, 'q': question, 'future': isFuture, 'at': createdAt, 'sliding': sliding.toJson(), 'wtf': wtf.toJson()};
  factory WhatfEntry.fromJson(Map<String, dynamic> j) => WhatfEntry(id: j['id'], question: j['q'], isFuture: j['future']==true, createdAt: j['at'], sliding: Scenario.fromJson(j['sliding']), wtf: Scenario.fromJson(j['wtf']));
}
