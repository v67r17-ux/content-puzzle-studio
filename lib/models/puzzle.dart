enum PuzzleType { crossword, wordSearch, sudoku, custom }

extension PuzzleTypeLabel on PuzzleType {
  String get label => switch (this) {
    PuzzleType.crossword => 'جدول کلمات متقاطع',
    PuzzleType.wordSearch => 'پیدا کردن کلمات',
    PuzzleType.sudoku => 'سودوکو',
    PuzzleType.custom => 'جدول اختصاصی',
  };
}

class Puzzle {
  const Puzzle({required this.id, required this.title, required this.type,
    required this.contentId, required this.createdAt});
  final String id;
  final String title;
  final PuzzleType type;
  final String? contentId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'type': type.name,
    'contentId': contentId, 'createdAt': createdAt.toIso8601String(),
  };
  factory Puzzle.fromJson(Map<String, dynamic> json) => Puzzle(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    type: PuzzleType.values.firstWhere((t) => t.name == json['type'],
      orElse: () => PuzzleType.custom),
    contentId: json['contentId'] as String?,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
