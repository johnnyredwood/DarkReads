import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import '../services/database_service.dart';
import 'service_providers.dart';

// Provider y Notifier de libros favoritos
class FavoriteBooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final DatabaseService _databaseService;

  FavoriteBooksNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _databaseService.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleFavorite(Book book) async {
    try {
      final isFav = await _databaseService.isFavorite(book.id);
      
      if (isFav) {
        await _databaseService.removeFavorite(book.id);
      } else {
        await _databaseService.addFavorite(book.id, book);
      }
      
      await _loadFavorites();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<bool> isFavorite(Book book) async {
    return await _databaseService.isFavorite(book.id);
  }

  Future<void> refresh() async {
    await _loadFavorites();
  }
}

final favoriteBooksProvider = StateNotifierProvider<FavoriteBooksNotifier, AsyncValue<List<Book>>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FavoriteBooksNotifier(databaseService);
});
