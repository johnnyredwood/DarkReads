import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/books_by_category_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/book_card.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horrorBooks = ref.watch(horrorBooksProvider);
    final mysteryBooks = ref.watch(mysteryBooksProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DarkReads',
          style: TextStyle(
            color: Color.fromARGB(255, 167, 25, 25),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                value: 'profile',
                child: Text(
                  currentUser?.username ?? 'Usuario',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authNotifierProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora el lado oscuro',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Categorías
            Text(
              'Categorías',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color.fromARGB(255, 167, 25, 25),
              ),
            ),
            const SizedBox(height: 12),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryCard(title: 'Terror', category: 'horror', icon: Icons.nightlight),
                  CategoryCard(title: 'Misterio', category: 'mystery', icon: Icons.search),
                  CategoryCard(title: 'Crimen', category: 'crime', icon: Icons.gavel),
                  CategoryCard(title: 'Thriller', category: 'thriller', icon: Icons.flash_on),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Libros populares de terror
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Libros de Terror Populares',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color.fromARGB(255, 167, 25, 25),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 167, 25, 25)),
                  onPressed: () {
                    ref.invalidate(horrorBooksProvider);
                  },
                  tooltip: 'Actualizar libros',
                ),
              ],
            ),
            const SizedBox(height: 12),
            horrorBooks.when(
              data: (books) => SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.take(10).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: BookCard(book: books[index]),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            
            // Libros de misterio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Misterios por Resolver',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color.fromARGB(255, 167, 25, 25),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 167, 25, 25)),
                  onPressed: () {
                    ref.invalidate(mysteryBooksProvider);
                  },
                  tooltip: 'Actualizar libros',
                ),
              ],
            ),
            const SizedBox(height: 12),
            mysteryBooks.when(
              data: (books) => SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.take(10).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: BookCard(book: books[index]),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}