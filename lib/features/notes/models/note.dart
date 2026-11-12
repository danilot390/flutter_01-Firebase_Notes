class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.isFavourite,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isFavourite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note copyWith({
    String? title,
    String? content,
    bool? isFavourite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      isFavourite: isFavourite ?? this.isFavourite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
