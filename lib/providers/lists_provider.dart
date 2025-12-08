import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import '../domain/entidades/favorite_list.dart';
import '../services/database_service.dart';
import 'service_providers.dart';

// Provider y Notifier de listas de favoritos
class FavoriteListsNotifier extends StateNotifier<AsyncValue<List<FavoriteList>>> {
  final DatabaseService _databaseService;

  FavoriteListsNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      final lists = await _databaseService.getAllLists();
      state = AsyncValue.data(lists);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createList(String name) async {
    try {
      await _databaseService.createList(name);
      await _loadLists();
    } catch (e) {
      print('Error creating list: $e');
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      await _databaseService.deleteList(listId);
      await _loadLists();
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  Future<void> renameList(String listId, String newName) async {
    try {
      await _databaseService.renameList(listId, newName);
      await _loadLists();
    } catch (e) {
      print('Error renaming list: $e');
    }
  }

  Future<void> refresh() async {
    await _loadLists();
  }
}

final favoriteListsProvider = StateNotifierProvider<FavoriteListsNotifier, AsyncValue<List<FavoriteList>>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FavoriteListsNotifier(databaseService);
});

// Provider de libros en una lista específica
final booksInListProvider = FutureProvider.family<List<Book>, String>((ref, listId) async {
  final databaseService = ref.read(databaseServiceProvider);
  return await databaseService.getBooksFromList(listId);
});

// Notifier de libros en una lista
class ListBooksNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final DatabaseService _databaseService;
  final String listId;

  ListBooksNotifier(this._databaseService, this.listId) : super(const AsyncValue.loading()) {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _databaseService.getBooksFromList(listId);
      state = AsyncValue.data(books);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await _databaseService.addBookToList(book.id, listId);
      await _loadBooks();
    } catch (e) {
      print('Error adding book to list: $e');
    }
  }

  Future<void> removeBook(String bookId) async {
    try {
      await _databaseService.removeBookFromList(listId, bookId);
      await _loadBooks();
    } catch (e) {
      print('Error removing book from list: $e');
    }
  }

  Future<bool> isBookInList(String bookId) async {
    return await _databaseService.isBookInList(bookId, listId);
  }

  Future<void> refresh() async {
    await _loadBooks();
  }
}

final listBooksProvider = StateNotifierProvider.family<ListBooksNotifier, AsyncValue<List<Book>>, String>((ref, listId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ListBooksNotifier(databaseService, listId);
});
