import '../../data/db/book_data.dart';
import '../../data/models/book_model.dart';

class EstudianteRepositorio {
  // Insertar un book
  Future<void> insertarBook(BookModel book) async {
    final db = await BookDb.instancia.database;
    await db.insert('favo', book.toMap());
  }

  // Obtener todos los books
  Future<List<BookModel>> obtenerBooks() async {
    final db = await BookDb.instancia.database;
    final List<Map<String, dynamic>> maps = await db.query('favo');
    return List.generate(maps.length, (i) {
      return BookModel.fromMap(maps[i]);
    });
  }

  // Eliminar book por ID
  Future<void> eliminarBook(String id) async {
    final db = await BookDb.instancia.database;
    await db.delete('favo', where: 'id = ?', whereArgs: [id]);
  }

}
