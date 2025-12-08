import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import '../providers/books_by_category_provider.dart';
import '../widgets/book_card.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;
  final String title;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> booksAsync = ref.watch(
      category == 'horror' ? horrorBooksProvider :
      category == 'mystery' ? mysteryBooksProvider :
      category == 'crime' ? crimeBooksProvider :
      thrillerBooksProvider
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Color.fromARGB(255, 167, 25, 25))),
      ),
      body: booksAsync.when(
        data: (books) => books.isEmpty
            ? const Center(child: Text('No se encontraron libros'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.46, // Ajustado para 120 width / 260 height
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return BookCard(book: books[index]);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}