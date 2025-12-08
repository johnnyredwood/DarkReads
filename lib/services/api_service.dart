import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/entidades/book_domain.dart';
import '../data/models/book_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String? _apiKey = null;
  
  Future<List<Book>> fetchBooksByCategory(String category) async {
    try {
      final url = _apiKey != null
          ? '$_baseUrl?q=subject:$category&maxResults=40&langRestrict=es&key=$_apiKey'
          : '$_baseUrl?q=subject:$category&maxResults=40&langRestrict=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null) {
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<List<Book>> fetchBooksByRating(int lowInt, int highInt) async {
    try {
      const url = _apiKey != null
          ? '$_baseUrl?q=subject:mystery,crime,horror,thriller&maxResults=10000&langRestrict=es&key=$_apiKey'
          : '$_baseUrl?q=subject:mystery,crime,horror,thriller&maxResults=10000&langRestrict=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null) {
          final books = items.map((item) => BookModel.fromJson(item)).toList();
          
          return books.where((book) {
            if (book.averageRating == null) return false;
            return book.averageRating! >= lowInt && book.averageRating! <= highInt;
          }).take(5).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    try {
      // Buscar por tÃ­tulo o autor
      final encodedQuery = Uri.encodeComponent(query);
      final url = _apiKey != null
          ? '$_baseUrl?q=$encodedQuery&maxResults=40&langRestrict=es&key=$_apiKey'
          : '$_baseUrl?q=$encodedQuery&maxResults=40&langRestrict=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null) {
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  /// Buscar libros por tÃ­tulo especÃ­ficamente
  Future<List<Book>> searchByTitle(String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title);
      final url = _apiKey != null
          ? '$_baseUrl?q=intitle:"$encodedTitle"&maxResults=40&langRestrict=es&key=$_apiKey'
          : '$_baseUrl?q=intitle:"$encodedTitle"&maxResults=40&langRestrict=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null) {
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error searching by title: $e');
    }
  }

  /// Buscar libros por autor especÃ­ficamente
  Future<List<Book>> searchByAuthor(String author) async {
    try {
      final encodedAuthor = Uri.encodeComponent(author);
      final url = _apiKey != null
          ? '$_baseUrl?q=inauthor:$encodedAuthor+subject:(mystery OR crime OR horror OR thriller)&maxResults=30&langRestrict=es&key=$_apiKey'
          : '$_baseUrl?q=inauthor:$encodedAuthor+subject:(mystery OR crime OR horror OR thriller)&maxResults=30&langRestrict=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        
        if (items != null) {
          return items.map((item) => BookModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Error searching by author: $e');
    }
  }

  /// Obtener un libro por su ID
  Future<Book?> fetchBookById(String bookId) async {
    try {
      final url = _apiKey != null
          ? '$_baseUrl/$bookId?key=$_apiKey'
          : '$_baseUrl/$bookId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching book by ID $bookId: $e');
      return null;
    }
  }
}
