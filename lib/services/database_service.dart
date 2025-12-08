import '../data/db/book_data.dart';
import '../domain/entidades/book_domain.dart';
import '../domain/entidades/user.dart';
import '../domain/entidades/comment.dart';
import '../domain/entidades/favorite_list.dart';
import 'api_service.dart';

class DatabaseService {
  final BookDb _db = BookDb.instancia;
  final ApiService _apiService = ApiService();
  String? _currentUserId;

  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

  String? get currentUserId => _currentUserId;
  
  Future<void> saveUser(User user) async {
    await _db.insertarUsuario(user);
  }

  Future<User?> getUserByEmail(String email) async {
    return await _db.obtenerUsuarioPorEmail(email);
  }

  Future<User?> getUserById(String userId) async {
    return await _db.obtenerUsuarioPorId(userId);
  }

  Future<bool> isEmailRegistered(String email) async {
    return await _db.emailRegistrado(email);
  }

  Future<bool> isUsernameInUse(String username) async {
    return await _db.usernameEnUso(username);
  }

  Future<List<User>> getAllUsers() async {
    return await _db.obtenerTodosUsuarios();
  }

  // ==================== SESIÓN ====================
  
  Future<void> setCurrentSession(String? userId) async {
    _currentUserId = userId;
    await _db.establecerSesion(userId);
  }

  Future<String?> getCurrentSessionUserId() async {
    return await _db.obtenerSesionActual();
  }

  
  Future<void> addFavorite(String bookId, Book book) async {
    if (_currentUserId == null) return;
    await _db.insertarDestacado(book, _currentUserId!);
  }

  Future<void> removeFavorite(String bookId) async {
    if (_currentUserId == null) return;
    await _db.eliminarDestacado(bookId, _currentUserId!);
  }

  Future<List<Book>> getFavorites() async {
    if (_currentUserId == null) return [];
    return await _db.cargarDestacados(_currentUserId!);
  }

  Future<bool> isFavorite(String bookId) async {
    if (_currentUserId == null) return false;
    return await _db.esFavorito(bookId, _currentUserId!);
  }
  
  Future<void> addComment(Comment comment) async {
    await _db.agregarComentario(comment);
  }

  Future<void> updateComment(String commentId, String newText) async {
    await _db.actualizarComentario(commentId, newText);
  }

  Future<void> deleteComment(String commentId) async {
    await _db.eliminarComentario(commentId);
  }

  Future<List<Comment>> getComments(String bookId) async {
    return await _db.obtenerComentarios(bookId);
  }

  Future<Comment?> getUserComment(String bookId, String userId) async {
    return await _db.obtenerComentarioUsuario(bookId, userId);
  }

  Future<Map<String, int>> getCommentStats(String bookId) async {
    return await _db.obtenerEstadisticasComentarios(bookId);
  }
  
  Future<void> createList(String name) async {
    if (_currentUserId == null) return;
    
    final lista = FavoriteList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      bookIds: [],
      createdAt: DateTime.now(),
    );
    
    await _db.crearLista(lista, _currentUserId!);
  }

  Future<void> deleteList(String listId) async {
    if (_currentUserId == null) return;
    await _db.eliminarLista(listId, _currentUserId!);
  }

  Future<void> renameList(String listId, String newName) async {
    if (_currentUserId == null) return;
    await _db.renombrarLista(listId, _currentUserId!, newName);
  }

  Future<List<FavoriteList>> getAllLists() async {
    if (_currentUserId == null) return [];
    return await _db.obtenerListas(_currentUserId!);
  }

  Future<void> addBookToList(String bookId, String listId) async {
    await _db.agregarLibroALista(listId, bookId);
  }

  Future<void> removeBookFromList(String listId, String bookId) async {
    await _db.removerLibroDeLista(listId, bookId);
  }

  Future<List<Book>> getBooksFromList(String listId) async {
    final bookIds = await _db.obtenerLibrosEnLista(listId);
    
    // Buscar cada libro en la API usando su ID
    List<Book> books = [];
    for (String bookId in bookIds) {
      try {
        final book = await _apiService.fetchBookById(bookId);
        if (book != null) {
          books.add(book);
        }
      } catch (e) {
        print('Error fetching book $bookId: $e');
      }
    }
    
    return books;
  }

  Future<bool> isBookInList(String bookId, String listId) async {
    return await _db.libroEstaEnLista(bookId, listId);
  }
}
