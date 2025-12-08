import 'package:flutter/foundation.dart';
import '../../domain/entidades/book_domain.dart';

class BookModel extends Book {
  BookModel({
    required super.id,
    required super.title,
    required super.authors,
    required super.thumbnail,
    required super.description,
    required super.averageRating,
    required super.ratingsCount,
    required super.publishedDate,
    required super.pageCount,
    super.category,
    super.previewLink,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    
    String? thumbnailUrl = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'];
    
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      thumbnailUrl = thumbnailUrl.replaceAll('http://', 'https://');
      
      // For web: Use CORS proxy to bypass restrictions
      if (kIsWeb) {
        thumbnailUrl = 'https://corsproxy.io/?${Uri.encodeComponent(thumbnailUrl)}';
      }
    }
    
    return BookModel(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Título no disponible',
      authors: List<String>.from(volumeInfo['authors'] ?? ['Autor desconocido']),
      thumbnail: thumbnailUrl,
      description: volumeInfo['description'] ?? 'Descripción no disponible',
      averageRating: (volumeInfo['averageRating'] ?? 0.0).toDouble(),
      ratingsCount: volumeInfo['ratingsCount'] ?? 0,
      publishedDate: volumeInfo['publishedDate'] ?? '',
      pageCount: volumeInfo['pageCount'] ?? 0,
      category: (volumeInfo['categories'] != null && (volumeInfo['categories'] as List).isNotEmpty)
          ? (volumeInfo['categories'] as List).first.toString()
          : null,
      previewLink: volumeInfo['previewLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'thumbnail': thumbnail,
      'description': description,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'publishedDate': publishedDate,
      'pageCount': pageCount,
      'category': category,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors.join(', '),
      'thumbnail': thumbnail,
      'description': description,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'publishedDate': publishedDate,
      'pageCount': pageCount,
      'category': category,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Título no disponible',
      authors: (map['authors'] as String).split(', '),
      thumbnail: map['thumbnail'],
      description: map['description'],
      averageRating: map['averageRating'] != null ? (map['averageRating'] as num).toDouble() : null,
      ratingsCount: map['ratingsCount'],
      publishedDate: map['publishedDate'],
      pageCount: map['pageCount'],
      category: map['category'],
    );
  }
}