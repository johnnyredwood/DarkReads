import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entidades/book_domain.dart';
import '../../domain/entidades/user.dart';
import '../../domain/entidades/comment.dart';
import '../../domain/entidades/favorite_list.dart';

// ---------- SQLite ----------
class BookDb {

  static final BookDb instancia = BookDb._internal();
  static Database? _db;

  factory BookDb() => instancia;
  BookDb._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  static Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'darkreads.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla de favoritos
        await db.execute('''
          CREATE TABLE favo(
            id TEXT PRIMARY KEY, 
            title TEXT NOT NULL,
            authors TEXT,
            thumbnail TEXT,
            description TEXT NOT NULL,
            averageRating REAL,
            ratingsCount INTEGER,
            publishedDate TEXT,
            pageCount INTEGER,
            categories TEXT,
            userId TEXT NOT NULL
          )
        ''');
        
        // Tabla de usuarios
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        
        // Tabla de sesión
        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            userId TEXT
          )
        ''');
        
        // Tabla de comentarios
        await db.execute('''
          CREATE TABLE comments(
            id TEXT PRIMARY KEY,
            bookId TEXT NOT NULL,
            userId TEXT NOT NULL,
            username TEXT NOT NULL,
            text TEXT NOT NULL,
            liked INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        
        // Tabla de listas de favoritos
        await db.execute('''
          CREATE TABLE lists(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        
        // Tabla de libros en listas
        await db.execute('''
          CREATE TABLE list_books(
            listId TEXT NOT NULL,
            bookId TEXT NOT NULL,
            PRIMARY KEY (listId, bookId)
          )
        ''');
        
        // Insertar sesión vacía
        await db.insert('session', {'id': 1, 'userId': null});
      },
    );
  }

  // ==================== FAVORITOS ====================
  
  // Insertar book destacado en SQLite
  Future<void> insertarDestacado(Book book, String userId) async {
    final db = await database;
    await db.insert(
      'favo',
      {
        'id': book.id, 
        'title': book.title,
        'authors': book.authors.join(', '),
        'thumbnail': book.thumbnail,
        'description': book.description,
        'averageRating': book.averageRating,
        'ratingsCount': book.ratingsCount,
        'publishedDate': book.publishedDate,
        'pageCount': book.pageCount,
        'categories': book.categories.join(', '),
        'userId': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Eliminar book destacado de SQLite
  Future<void> eliminarDestacado(String id, String userId) async {
    final db = await database;
    await db.delete(
      'favo',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // Cargar todos los books destacados desde SQLite
  Future<List<Book>> cargarDestacados(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favo',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        authors: (maps[i]['authors'] as String).split(', '),
        thumbnail: maps[i]['thumbnail'] as String?,
        description: maps[i]['description'] as String,
        averageRating: maps[i]['averageRating'] as double?,
        ratingsCount: maps[i]['ratingsCount'] as int?,
        publishedDate: maps[i]['publishedDate'] as String?,
        pageCount: maps[i]['pageCount'] as int?,
        categories: (maps[i]['categories'] as String).split(', '),
      );
    });
  }
  
  // Verificar si un libro es favorito
  Future<bool> esFavorito(String bookId, String userId) async {
    final db = await database;
    final result = await db.query(
      'favo',
      where: 'id = ? AND userId = ?',
      whereArgs: [bookId, userId],
    );
    return result.isNotEmpty;
  }

  // ==================== USUARIOS ====================
  
  Future<void> insertarUsuario(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'passwordHash': user.passwordHash,
        'createdAt': user.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<User?> obtenerUsuarioPorEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    
    if (maps.isEmpty) return null;
    
    return User(
      id: maps[0]['id'] as String,
      username: maps[0]['username'] as String,
      email: maps[0]['email'] as String,
      passwordHash: maps[0]['passwordHash'] as String,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
    );
  }
  
  Future<User?> obtenerUsuarioPorId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isEmpty) return null;
    
    return User(
      id: maps[0]['id'] as String,
      username: maps[0]['username'] as String,
      email: maps[0]['email'] as String,
      passwordHash: maps[0]['passwordHash'] as String,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
    );
  }
  
  Future<bool> emailRegistrado(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty;
  }
  
  Future<bool> usernameEnUso(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
    );
    return result.isNotEmpty;
  }
  
  Future<List<User>> obtenerTodosUsuarios() async {
    final db = await database;
    final maps = await db.query('users');
    
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'] as String,
        username: maps[i]['username'] as String,
        email: maps[i]['email'] as String,
        passwordHash: maps[i]['passwordHash'] as String,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
      );
    });
  }

  // ==================== SESIÓN ====================
  
  Future<void> establecerSesion(String? userId) async {
    final db = await database;
    await db.update(
      'session',
      {'userId': userId},
      where: 'id = 1',
    );
  }
  
  Future<String?> obtenerSesionActual() async {
    final db = await database;
    final maps = await db.query('session', where: 'id = 1');
    if (maps.isEmpty) return null;
    return maps[0]['userId'] as String?;
  }

  // ==================== COMENTARIOS ====================
  
  Future<void> agregarComentario(Comment comment) async {
    final db = await database;
    await db.insert(
      'comments',
      {
        'id': comment.id,
        'bookId': comment.bookId,
        'userId': comment.userId,
        'username': comment.username,
        'text': comment.text,
        'liked': comment.liked ? 1 : 0,
        'createdAt': comment.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> actualizarComentario(String commentId, String nuevoTexto) async {
    final db = await database;
    await db.update(
      'comments',
      {'text': nuevoTexto},
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }
  
  Future<void> eliminarComentario(String commentId) async {
    final db = await database;
    await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }
  
  Future<List<Comment>> obtenerComentarios(String bookId) async {
    final db = await database;
    final maps = await db.query(
      'comments',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Comment(
        id: maps[i]['id'] as String,
        bookId: maps[i]['bookId'] as String,
        userId: maps[i]['userId'] as String,
        username: maps[i]['username'] as String,
        text: maps[i]['text'] as String,
        liked: (maps[i]['liked'] as int) == 1,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
      );
    });
  }
  
  Future<Comment?> obtenerComentarioUsuario(String bookId, String userId) async {
    final db = await database;
    final maps = await db.query(
      'comments',
      where: 'bookId = ? AND userId = ?',
      whereArgs: [bookId, userId],
    );
    
    if (maps.isEmpty) return null;
    
    return Comment(
      id: maps[0]['id'] as String,
      bookId: maps[0]['bookId'] as String,
      userId: maps[0]['userId'] as String,
      username: maps[0]['username'] as String,
      text: maps[0]['text'] as String,
      liked: (maps[0]['liked'] as int) == 1,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
    );
  }
  
  Future<Map<String, int>> obtenerEstadisticasComentarios(String bookId) async {
    final db = await database;
    final maps = await db.query(
      'comments',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    
    final liked = maps.where((m) => (m['liked'] as int) == 1).length;
    final disliked = maps.where((m) => (m['liked'] as int) == 0).length;
    
    return {
      'total': maps.length,
      'liked': liked,
      'disliked': disliked,
    };
  }

  // ==================== LISTAS ====================
  
  Future<void> crearLista(FavoriteList lista, String userId) async {
    final db = await database;
    await db.insert(
      'lists',
      {
        'id': lista.id,
        'userId': userId,
        'name': lista.name,
        'createdAt': lista.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<void> eliminarLista(String listId, String userId) async {
    final db = await database;
    await db.delete(
      'lists',
      where: 'id = ? AND userId = ?',
      whereArgs: [listId, userId],
    );
    await db.delete(
      'list_books',
      where: 'listId = ?',
      whereArgs: [listId],
    );
  }
  
  Future<void> renombrarLista(String listId, String userId, String nuevoNombre) async {
    final db = await database;
    await db.update(
      'lists',
      {'name': nuevoNombre},
      where: 'id = ? AND userId = ?',
      whereArgs: [listId, userId],
    );
  }
  
  Future<List<FavoriteList>> obtenerListas(String userId) async {
    final db = await database;
    final maps = await db.query(
      'lists',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
    
    List<FavoriteList> listas = [];
    for (var map in maps) {
      final bookIds = await obtenerLibrosEnLista(map['id'] as String);
      listas.add(FavoriteList(
        id: map['id'] as String,
        name: map['name'] as String,
        bookIds: bookIds,
        createdAt: DateTime.parse(map['createdAt'] as String),
      ));
    }
    return listas;
  }
  
  Future<void> agregarLibroALista(String listId, String bookId) async {
    final db = await database;
    await db.insert(
      'list_books',
      {
        'listId': listId,
        'bookId': bookId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
  
  Future<void> removerLibroDeLista(String listId, String bookId) async {
    final db = await database;
    await db.delete(
      'list_books',
      where: 'listId = ? AND bookId = ?',
      whereArgs: [listId, bookId],
    );
  }
  
  Future<List<String>> obtenerLibrosEnLista(String listId) async {
    final db = await database;
    final maps = await db.query(
      'list_books',
      where: 'listId = ?',
      whereArgs: [listId],
    );
    return List.generate(maps.length, (i) => maps[i]['bookId'] as String);
  }
  
  Future<bool> libroEstaEnLista(String bookId, String listId) async {
    final db = await database;
    final result = await db.query(
      'list_books',
      where: 'listId = ? AND bookId = ?',
      whereArgs: [listId, bookId],
    );
    return result.isNotEmpty;
  }
}
