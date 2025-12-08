import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../domain/entidades/book_domain.dart';
import '../widgets/book_card.dart';

enum SearchType { all, title, author }

final searchProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  SearchType _searchType = SearchType.all;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final apiService = ApiService();
      List<Book> results;
      
      switch (_searchType) {
        case SearchType.title:
          results = await apiService.searchByTitle(query);
        case SearchType.author:
          results = await apiService.searchByAuthor(query);
        case SearchType.all:
          results = await apiService.searchBooks(query);
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: _searchType == SearchType.title
                ? 'Buscar por título...'
                : _searchType == SearchType.author
                    ? 'Buscar por autor...'
                    : 'Buscar libros...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          autofocus: true,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
          PopupMenuButton<SearchType>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Tipo de búsqueda',
            onSelected: (SearchType type) {
              setState(() {
                _searchType = type;
              });
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: SearchType.all,
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: _searchType == SearchType.all ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Buscar todo',
                      style: TextStyle(
                        fontWeight: _searchType == SearchType.all ? FontWeight.bold : null,
                        color: _searchType == SearchType.all ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SearchType.title,
                child: Row(
                  children: [
                    Icon(
                      Icons.title,
                      size: 20,
                      color: _searchType == SearchType.title ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Solo título',
                      style: TextStyle(
                        fontWeight: _searchType == SearchType.title ? FontWeight.bold : null,
                        color: _searchType == SearchType.title ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SearchType.author,
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: _searchType == SearchType.author ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Solo autor',
                      style: TextStyle(
                        fontWeight: _searchType == SearchType.author ? FontWeight.bold : null,
                        color: _searchType == SearchType.author ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador del tipo de búsqueda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              children: [
                Icon(
                  _searchType == SearchType.title
                      ? Icons.title
                      : _searchType == SearchType.author
                          ? Icons.person
                          : Icons.search,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  _searchType == SearchType.title
                      ? 'Buscando por título en: Mystery, Crime, Horror, Thriller'
                      : _searchType == SearchType.author
                          ? 'Buscando por autor en: Mystery, Crime, Horror, Thriller'
                          : 'Buscando en: Mystery, Crime, Horror, Thriller',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron resultados',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otro término de búsqueda',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 64, color: Colors.grey[600]),
                                const SizedBox(height: 16),
                                Text(
                                  'Busca libros de terror, misterio, crimen...',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ejemplos de búsqueda:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildSearchExample('• "Drácula"'),
                                      _buildSearchExample('• "Stephen King"'),
                                      _buildSearchExample('• "Agatha Christie"'),
                                      _buildSearchExample('• "Sherlock Holmes"'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return BookCard(book: _searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchExample(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}