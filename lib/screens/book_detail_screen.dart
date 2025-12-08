import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import '../providers/favorites_provider.dart';
import '../providers/lists_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/comments_provider.dart';
import '../providers/service_providers.dart';
import 'ai_summary_screen.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await ref.read(favoriteBooksProvider.notifier).isFavorite(widget.book);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesNotifier = ref.watch(favoriteBooksProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Libro', style: TextStyle(color: Color.fromARGB(255, 167, 25, 25))),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? const Color.fromARGB(255, 167, 25, 25) : null,
            ),
            onPressed: () async {
              await favoritesNotifier.toggleFavorite(widget.book);
              setState(() {
                _isFavorite = !_isFavorite;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorite 
                        ? 'Agregado a favoritos' 
                        : 'Eliminado de favoritos',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () => _showAddToListDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: widget.book.thumbnail != null
                      ? Image.network(
                          widget.book.thumbnail!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book, color: Colors.grey, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.book.authors.join(', '),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.book.averageRating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.book.averageRating} (${widget.book.ratingsCount} reseñas)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      if (widget.book.publishedDate != null)
                        Text(
                          'Publicado: ${widget.book.publishedDate}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (widget.book.pageCount != null)
                        Text(
                          'Páginas: ${widget.book.pageCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description ?? 'Descripción no disponible',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            if (widget.book.categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.book.categories.map((category) {
                      return Chip(
                        label: Text(category),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAiSummaryDialog(context),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Resumen con IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await favoritesNotifier.toggleFavorite(widget.book);
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? const Color.fromARGB(255, 167, 25, 25) : null,
                    ),
                    label: Text(_isFavorite ? 'En Favoritos' : 'Agregar a Favoritos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    final currentUser = ref.watch(currentUserProvider);
    final commentsAsync = ref.watch(bookCommentsNotifierProvider(widget.book.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comentarios',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentUser != null)
              FilledButton.icon(
                onPressed: () => _showAddCommentDialog(currentUser),
                icon: const Icon(Icons.add_comment, size: 18),
                label: const Text('Comentar'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        commentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
          data: (comments) {
            if (comments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay comentarios aún.\n¡Sé el primero en comentar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final isMyComment = comment.userId == currentUser?.id;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text(comment.username[0].toUpperCase()),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.username,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (isMyComment) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Tú',
                                            style: TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    _formatDate(comment.createdAt),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              comment.liked ? Icons.thumb_up : Icons.thumb_down,
                              size: 20,
                              color: comment.liked ? Colors.green : const Color.fromARGB(255, 167, 25, 25),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(comment.text),
                        if (isMyComment) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showEditCommentDialog(comment),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteComment(comment.id),
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Eliminar'),
                                style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 167, 25, 25)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return 'hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora';
    }
  }

  void _showAddCommentDialog(currentUser) {
    final textController = TextEditingController();
    bool liked = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Comentario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Tu comentario',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16),
                        SizedBox(width: 4),
                        Text('Me gustó'),
                      ],
                    ),
                    selected: liked,
                    onSelected: (value) => setState(() => liked = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Row(
                      children: [
                        Icon(Icons.thumb_down, size: 16),
                        SizedBox(width: 4),
                        Text('No me gustó'),
                      ],
                    ),
                    selected: !liked,
                    onSelected: (value) => setState(() => liked = false),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (textController.text.trim().isNotEmpty) {
                  await ref.read(bookCommentsNotifierProvider(widget.book.id).notifier).addComment(
                    userId: currentUser.id,
                    username: currentUser.username,
                    text: textController.text.trim(),
                    liked: liked,
                  );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCommentDialog(comment) {
    final textController = TextEditingController(text: comment.text);
    bool liked = comment.liked;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Comentario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Tu comentario',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16),
                        SizedBox(width: 4),
                        Text('Me gustó'),
                      ],
                    ),
                    selected: liked,
                    onSelected: (value) => setState(() => liked = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Row(
                      children: [
                        Icon(Icons.thumb_down, size: 16),
                        SizedBox(width: 4),
                        Text('No me gustó'),
                      ],
                    ),
                    selected: !liked,
                    onSelected: (value) => setState(() => liked = false),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (textController.text.trim().isNotEmpty) {
                  await ref.read(bookCommentsNotifierProvider(widget.book.id).notifier).updateComment(
                    commentId: comment.id,
                    text: textController.text.trim(),
                    liked: liked,
                  );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Comentario'),
        content: const Text('¿Estás seguro de que quieres eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(bookCommentsNotifierProvider(widget.book.id).notifier).deleteComment(commentId);
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color.fromARGB(255, 167, 25, 25)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddToListDialog(BuildContext context) {
    final listsAsync = ref.read(favoriteListsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar a Lista'),
        content: listsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
          data: (lists) {
            if (lists.isEmpty) {
              return const Text('No tienes listas creadas');
            }
            
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ListTile(
                    leading: Icon(
                      list.id == 'default' ? Icons.star : Icons.folder,
                      color: list.id == 'default' ? Colors.amber : Colors.blue,
                    ),
                    title: Text(list.name),
                    subtitle: Text('${list.bookIds.length} libros'),
                    onTap: () async {
                      final databaseService = ref.read(databaseServiceProvider);
                      await databaseService.addBookToList(widget.book.id, list.id);
                      ref.invalidate(listBooksProvider(list.id));
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Agregado a "${list.name}"'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAiSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f3460),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Color(0xFF4ecca3)),
            SizedBox(width: 12),
            Text(
              'Resumen con IA',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elige el tipo de resumen que deseas:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.visibility_off,
                color: Color(0xFF4ecca3),
              ),
              title: const Text(
                'Sin Spoilers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Resumen general sin revelar la trama',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              tileColor: const Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AiSummaryScreen(
                      book: widget.book,
                      withSpoilers: false,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.warning,
                color: Color(0xFFe94560),
              ),
              title: const Text(
                'Con Spoilers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Resumen completo incluyendo el final',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              tileColor: const Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AiSummaryScreen(
                      book: widget.book,
                      withSpoilers: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4ecca3)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
