import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/comment.dart';
import '../services/database_service.dart';
import 'service_providers.dart';

// Providers de comentarios
final bookCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, bookId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getComments(bookId);
});

final commentStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, bookId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getCommentStats(bookId);
});

// Notifier de comentarios de un libro
class BookCommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final DatabaseService _databaseService;
  final String bookId;
  
  BookCommentsNotifier(this._databaseService, this.bookId) : super(const AsyncValue.loading()) {
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _databaseService.getComments(bookId);
      state = AsyncValue.data(comments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addComment({
    required String userId,
    required String username,
    required String text,
    required bool liked,
  }) async {
    try {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookId,
        userId: userId,
        username: username,
        text: text,
        liked: liked,
        createdAt: DateTime.now(),
      );
      await _databaseService.addComment(comment);
      await _loadComments();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> updateComment({
    required String commentId,
    required String text,
    required bool liked,
  }) async {
    try {
      await _databaseService.updateComment(commentId, text);
      await _loadComments();
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _databaseService.deleteComment(commentId);
      await _loadComments();
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  Future<Comment?> getUserComment(String userId) async {
    return await _databaseService.getUserComment(bookId, userId);
  }

  Future<void> refresh() async {
    await _loadComments();
  }
}

final bookCommentsNotifierProvider = StateNotifierProvider.family<BookCommentsNotifier, AsyncValue<List<Comment>>, String>((ref, bookId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return BookCommentsNotifier(databaseService, bookId);
});
