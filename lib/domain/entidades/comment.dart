class Comment {
  final String id;
  final String bookId;
  final String userId;
  final String username; // Para mostrar sin hacer lookup adicional
  final String text;
  final bool liked; // true = me gustó, false = no me gustó
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.username,
    required this.text,
    required this.liked,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? username,
    String? text,
    bool? liked,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      text: text ?? this.text,
      liked: liked ?? this.liked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
