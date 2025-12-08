import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import 'service_providers.dart';

// Providers de libros por categoría
final horrorBooksProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final books = await apiService.fetchBooksByCategory('horror');
  books.shuffle();
  return books;
});

final mysteryBooksProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final books = await apiService.fetchBooksByCategory('mystery');
  books.shuffle();
  return books;
});

final crimeBooksProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final books = await apiService.fetchBooksByCategory('crime');
  books.shuffle();
  return books;
});

final thrillerBooksProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final books = await apiService.fetchBooksByCategory('thriller');
  books.shuffle();
  return books;
});

final bestRatedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.fetchBooksByCategory('best rated');
});

final midRatedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.fetchBooksByCategory('mid rated');
});

final lowRatedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.fetchBooksByCategory('low rated');
});
