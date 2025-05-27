import 'quran_verse.dart';

class QuranChapter {
  final int number;
  final Map<String, String> name;
  final Map<String, String> revelationPlace;
  final int versesCount;
  final int wordsCount;
  final int lettersCount;
  final List<QuranVerse> verses;
  final List<Audio> audio;

  QuranChapter({
    required this.number,
    required this.name,
    required this.revelationPlace,
    required this.versesCount,
    required this.wordsCount,
    required this.lettersCount,
    required this.verses,
    required this.audio,
  });

  factory QuranChapter.fromJson(Map<String, dynamic> json) {
    return QuranChapter(
      number: json['number'] ?? 0,
      name: Map<String, String>.from(json['name'] ?? {}),
      revelationPlace: Map<String, String>.from(json['revelation_place'] ?? {}),
      versesCount: json['verses_count'] ?? 0,
      wordsCount: json['words_count'] ?? 0,
      lettersCount: json['letters_count'] ?? 0,
      verses: (json['verses'] as List? ?? [])
          .map((verse) => QuranVerse.fromJson(verse))
          .toList(),
      audio: (json['audio'] as List? ?? [])
          .map((audio) => Audio.fromJson(audio))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'revelation_place': revelationPlace,
      'verses_count': versesCount,
      'words_count': wordsCount,
      'letters_count': lettersCount,
      'verses': verses.map((verse) => verse.toJson()).toList(),
      'audio': audio.map((audio) => audio.toJson()).toList(),
    };
  }
}

class Audio {
  final int id;
  final Map<String, String> reciter;
  final Map<String, String> rewaya;
  final String server;
  final String link;

  Audio({
    required this.id,
    required this.reciter,
    required this.rewaya,
    required this.server,
    required this.link,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['id'],
      reciter: Map<String, String>.from(json['reciter']),
      rewaya: Map<String, String>.from(json['rewaya']),
      server: json['server'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reciter': reciter,
      'rewaya': rewaya,
      'server': server,
      'link': link,
    };
  }
}
