// ---------- Entidad ----------
class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String? thumbnail;
  final String? description;
  final double? averageRating;
  final int? ratingsCount;
  final String? publishedDate;
  final int? pageCount;
  final List<String> categories;
  final String? previewLink;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnail,
    this.description,
    this.averageRating,
    this.ratingsCount,
    this.publishedDate,
    this.pageCount,
    this.categories = const [],
    this.previewLink,
  });
}