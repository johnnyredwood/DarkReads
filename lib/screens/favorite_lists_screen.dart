import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lists_provider.dart';
import '../domain/entidades/favorite_list.dart';
import 'list_detail_screen.dart';

class FavoriteListsScreen extends ConsumerWidget {
  const FavoriteListsScreen({super.key});

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
            hintText: 'Ej: Libros de Terror',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(favoriteListsProvider.notifier).createList(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showRenameListDialog(BuildContext context, WidgetRef ref, FavoriteList list) {
    final controller = TextEditingController(text: list.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar Lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(favoriteListsProvider.notifier).renameList(list.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, FavoriteList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text('¿Estás seguro de que quieres eliminar "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(favoriteListsProvider.notifier).deleteList(list.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color.fromARGB(255, 167, 25, 25)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(favoriteListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Listas de Favoritos', style: TextStyle(color: Color.fromARGB(255, 167, 25, 25))),
        elevation: 0,
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Color.fromARGB(255, 167, 25, 25)),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(favoriteListsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes listas de favoritos',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera lista para organizar tus libros',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              final isDefault = list.id == 'default';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDefault ? const Color.fromARGB(255, 0, 0, 0) : Colors.blue,
                    child: Icon(
                      isDefault ? Icons.star : Icons.folder,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${list.bookIds.length} ${list.bookIds.length == 1 ? 'libro' : 'libros'}',
                  ),
                  trailing: !isDefault
                      ? PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Renombrar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Color.fromARGB(255, 167, 25, 25)),
                                  SizedBox(width: 8),
                                  Text('Eliminar', style: TextStyle(color: Color.fromARGB(255, 167, 25, 25))),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'rename') {
                              _showRenameListDialog(context, ref, list);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, ref, list);
                            }
                          },
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListDetailScreen(list: list),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Lista'),
      ),
    );
  }
}
