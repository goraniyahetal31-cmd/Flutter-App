/// Single blog / micro-post stored locally (SQLite on Android & iOS).
class BlogMessage {
  BlogMessage({
    this.id,
    this.title = '',
    required this.body,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String body;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogMessage copyWith({
    int? id,
    String? title,
    String? body,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImage = false,
  }) {
    return BlogMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'image_path': imagePath,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  static BlogMessage fromMap(Map<String, Object?> map) {
    return BlogMessage(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
