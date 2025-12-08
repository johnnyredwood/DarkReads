import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/book_card.dart';
import 'favorite_lists_screen.dart';
import '../domain/entidades/book_domain.dart';
import '../services/gemini_service.dart';

// Función top-level para ejecutar en isolate
Future<String> _generateRecommendationsInIsolate(List<Book> books) async {
  final geminiService = GeminiService();
  return await geminiService.generatePersonalizedRecommendations(books);
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteBooksAsync = ref.watch(favoriteBooksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos', style: TextStyle(color: Color.fromARGB(255, 167, 25, 25))),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special),
            tooltip: 'Ver todas las listas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteListsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: favoriteBooksAsync.when(
        data: (favoriteBooks) {
          if (favoriteBooks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tus libros favoritos aparecerán aquí',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guarda tus libros favoritos desde los detalles',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Mostrar diálogo de carga
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: Card(
                          color: Colors.grey,
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: Color.fromARGB(255, 101, 11, 11),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Generando recomendaciones...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    try {
                      // Ejecutar en isolate
                      final receivePort = ReceivePort();
                      await Isolate.spawn(
                        (SendPort sendPort) async {
                          try {
                            final recommendations = await _generateRecommendationsInIsolate(favoriteBooks);
                            sendPort.send({'success': true, 'data': recommendations});
                          } catch (e) {
                            sendPort.send({'success': false, 'error': e.toString()});
                          }
                        },
                        receivePort.sendPort,
                      );

                      final result = await receivePort.first as Map<String, dynamic>;
                      
                      if (context.mounted) {
                        // Cerrar diálogo de carga
                        Navigator.pop(context);
                        
                        if (result['success'] == true) {
                          // Mostrar recomendaciones
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Recomendaciones IA',
                                style: TextStyle(color: Color.fromARGB(255, 167, 25, 25)),
                              ),
                              content: SingleChildScrollView(
                                child: Text(
                                  result['data'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cerrar',
                                    style: TextStyle(color: Color.fromARGB(255, 167, 25, 25)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Mostrar error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${result['error']}'),
                              backgroundColor: const Color.fromARGB(255, 167, 25, 25),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Cerrar diálogo de carga
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al generar recomendaciones: $e'),
                            backgroundColor: const Color.fromARGB(255, 167, 25, 25),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar Sugerencias IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 102, 7, 7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: favoriteBooks.length,
                  itemBuilder: (context, index) {
                    return BookCard(book: favoriteBooks[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color.fromARGB(255, 167, 25, 25)),
              const SizedBox(height: 16),
              Text(
                'Error al cargar favoritos',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}