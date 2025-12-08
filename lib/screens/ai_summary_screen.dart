import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/book_domain.dart';
import '../providers/service_providers.dart';

class AiSummaryScreen extends ConsumerStatefulWidget {
  final Book book;
  final bool withSpoilers;

  const AiSummaryScreen({
    super.key,
    required this.book,
    required this.withSpoilers,
  });

  @override
  ConsumerState<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends ConsumerState<AiSummaryScreen> {
  bool _isLoading = true;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoading = true;
    });

    final geminiService = ref.read(geminiServiceProvider);
    
    try {
      final summary = widget.withSpoilers
          ? await geminiService.generateSummaryWithSpoilers(widget.book)
          : await geminiService.generateSummaryWithoutSpoilers(widget.book);
      
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _summary = 'Error al generar el resumen: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.withSpoilers ? 'Resumen con Spoilers' : 'Resumen sin Spoilers',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        decoration: null,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Generando resumen con IA...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del libro
                    Card(
                      color: Colors.grey[900],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (widget.book.thumbnail != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.book.thumbnail!,
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.book, color: Colors.white54),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.book.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.book.authors.join(', '),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo de resumen
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.withSpoilers
                            ? const Color(0xFFe94560).withOpacity(0.2)
                            : const Color(0xFF4ecca3).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.withSpoilers
                              ? const Color(0xFFe94560)
                              : const Color(0xFF4ecca3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.withSpoilers ? Icons.warning : Icons.visibility_off,
                            color: widget.withSpoilers
                                ? const Color(0xFFe94560)
                                : const Color(0xFF4ecca3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.withSpoilers
                                  ? '⚠️ Este resumen contiene SPOILERS'
                                  : '✨ Resumen sin spoilers',
                              style: TextStyle(
                                color: widget.withSpoilers
                                    ? const Color(0xFFe94560)
                                    : const Color(0xFF4ecca3),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resumen generado por IA
                    Card(
                      color: Colors.grey[900],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/gemini_icon.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFF4ecca3),
                                      size: 24,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Resumen generado por Gemini AI',
                                  style: TextStyle(
                                    color: Color(0xFF4ecca3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _summary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón para regenerar
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _generateSummary,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerar resumen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe94560),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
