enum ContentMode { richText, blocks }

class ContentBlock {
  const ContentBlock({required this.id, required this.type, required this.text});
  final String id;
  final String type;
  final String text;

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'text': text};
  factory ContentBlock.fromJson(Map<String, dynamic> json) => ContentBlock(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    type: json['type'] as String? ?? 'text',
    text: json['text'] as String? ?? '',
  );
}

class ContentItem {
  const ContentItem({
    required this.id, required this.title, required this.body,
    required this.category, required this.tags, required this.mode,
    required this.blocks, required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final List<String> tags;
  final ContentMode mode;
  final List<ContentBlock> blocks;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body, 'category': category,
    'tags': tags, 'mode': mode.name,
    'blocks': blocks.map((b) => b.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    category: json['category'] as String? ?? 'عمومی',
    tags: (json['tags'] as List? ?? []).cast<String>(),
    mode: ContentMode.values.firstWhere(
      (m) => m.name == json['mode'], orElse: () => ContentMode.richText),
    blocks: (json['blocks'] as List? ?? [])
      .map((b) => ContentBlock.fromJson(Map<String, dynamic>.from(b as Map))).toList(),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
