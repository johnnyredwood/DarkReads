class FavoriteList {
  final String id;
  final String name;
  final List<String> bookIds; // IDs de los libros en esta lista
  final DateTime createdAt;

  FavoriteList({
    required this.id,
    required this.name,
    required this.bookIds,
    required this.createdAt,
  });

  FavoriteList copyWith({
    String? id,
    String? name,
    List<String>? bookIds,
    DateTime? createdAt,
  }) {
    return FavoriteList(
      id: id ?? this.id,
      name: name ?? this.name,
      bookIds: bookIds ?? this.bookIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
