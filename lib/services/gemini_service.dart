import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entidades/book_domain.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  GenerativeModel? _model;
  
  GeminiService() {
    if (_apiKey.isNotEmpty) {
      try {
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: _apiKey,
        );
      } catch (e) {
        print('Error inicializando modelo Gemini: $e');
        throw Exception('Error al inicializar Gemini: $e');
      }
    } else {
      throw Exception('GEMINI_API_KEY no configurada en .env');
    }
  }

  Future<String> generateSummaryWithoutSpoilers(Book book) async {
    try {
      final prompt = '''
Eres un experto en literatura de misterio, crimen y terror. 
Genera un resumen atractivo y profesional del siguiente libro SIN REVELAR SPOILERS.

Título: ${book.title}
Autor: ${book.authors.join(', ')}
${book.description != null ? 'Descripción original: ${book.description}' : ''}

El resumen debe:
- Ser conciso (máximo 150 palabras)
- Crear intriga sin revelar giros importantes
- Mencionar el género y el ambiente
- Ser atractivo para motivar la lectura
- NO revelar el final ni giros importantes de la trama
- Estar en español

Resumen:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'No se pudo generar el resumen.';
    } catch (e) {
      throw Exception('Error al generar resumen: $e');
    }
  }

  Future<String> generateSummaryWithSpoilers(Book book) async {
    try {
      final prompt = '''
Eres un experto en literatura de misterio, crimen y terror.
Genera un resumen COMPLETO del siguiente libro INCLUYENDO SPOILERS.

Título: ${book.title}
Autor: ${book.authors.join(', ')}
${book.description != null ? 'Descripción original: ${book.description}' : ''}

El resumen debe:
- Ser detallado (máximo 250 palabras)
- Revelar los giros importantes de la trama
- Explicar el desenlace y las revelaciones principales
- Analizar brevemente los temas principales
- Estar en español
- Comenzar con "ADVERTENCIA: ESTE RESUMEN CONTIENE SPOILERS ⚠️"

Resumen:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'No se pudo generar el resumen.';
    } catch (e) {
      throw Exception('Error al generar resumen: $e');
    }
  }

  Future<String> generatePersonalizedRecommendations(List<Book> favoriteBooks) async {
    if (favoriteBooks.isEmpty) {
      return 'Agrega algunos libros a tus favoritos para recibir recomendaciones personalizadas.';
    }

    try {
      final booksInfo = favoriteBooks.take(5).map((book) {
        return '- ${book.title} por ${book.authors.join(', ')}';
      }).join('\n');

      final prompt = '''
Eres un experto en literatura de misterio, crimen y terror.
Basándote en los siguientes libros favoritos del usuario, genera 5 recomendaciones personalizadas:

Libros favoritos:
$booksInfo

Por favor proporciona:
1. 5 títulos de libros recomendados (con autor)
2. Una breve explicación (1-2 líneas) de por qué cada libro es una buena recomendación
3. Asegúrate de que sean libros del género de misterio, crimen o terror
4. Responde en español
5. Formato: "*[Título] - [Autor]\n   Razón: [explicación breve]\n"

Recomendaciones:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'No se pudieron generar recomendaciones.';
    } catch (e) {
      throw Exception('Error al generar recomendaciones: $e');
    }
  }

  Future<String> generatePersonalizedRecommendationBookCard(Book selectedBook) async {
    if (selectedBook.title.isEmpty) {
      return 'No hay ningún libro seleccionado para recibir recomendaciones personalizadas.';
    }

    try {
      final prompt = '''
Eres un experto en literatura de misterio, crimen y terror.
Basándote en el siguiente libro favorito del usuario, genera 5 recomendaciones personalizadas:

Libro favorito:
${selectedBook.title} por ${selectedBook.authors.join(', ')}

Por favor proporciona:
1. 5 títulos de libros recomendados (con autor)
2. Una breve explicación (1-2 líneas) de por qué cada libro es una buena recomendación
3. Asegúrate de que sean libros del género de misterio, crimen o terror
4. Responde en español
5. Formato: "*[Título] - [Autor]\n   Razón: [explicación breve]\n"

Recomendaciones:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'No se pudieron generar recomendaciones.';
    } catch (e) {
      throw Exception('Error al generar recomendaciones: $e');
    }
  }
}
