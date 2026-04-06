import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../widgets/product_tile.dart';
import '../widgets/search_bar_field.dart';
import 'admin/book_form_screen.dart';

class BooksScreen extends StatefulWidget {
  final VoidCallback onCartChanged;
  final bool isAdmin;
  const BooksScreen({super.key, required this.onCartChanged, required this.isAdmin});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _api        = ApiService();
  final _searchCtrl = TextEditingController();
  List<Book> _all   = [];
  List<Book> _shown = [];
  bool _loading     = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final books = await _api.getBooks();
      if (!mounted) return;
      setState(() { _all = books; _filter(_searchCtrl.text); });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _shown = q.isEmpty
          ? List.from(_all)
          : _all.where((b) =>
              b.title.toLowerCase().contains(lower) ||
              b.author.toLowerCase().contains(lower)).toList();
    });
  }

  Future<void> _addToCart(int id) async {
    try {
      await _api.addToCart(id);
      widget.onCartChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openForm([Book? book]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(Book book) async {
    final confirmed = await _confirmDelete(context, book.title);
    if (!confirmed) return;
    try {
      await _api.deleteBook(book.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(message: _error!, onRetry: _load);

    return Scaffold(
      body: Column(children: [
        SearchBarField(
          controller: _searchCtrl,
          hint: 'Search by title or author…',
          onChanged: _filter,
        ),
        if (_shown.isEmpty)
          const Expanded(child: Center(child: Text('No books match your search.')))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _shown.length,
                itemBuilder: (_, i) {
                  final b = _shown[i];
                  return ProductTile(
                    emoji: '📚',
                    title: b.title,
                    subtitle: 'by ${b.author} · ${b.copies} copies',
                    price: '\$${b.price.toStringAsFixed(2)}',
                    onAddToCart: () => _addToCart(b.id),
                    onEdit:   widget.isAdmin ? () => _openForm(b) : null,
                    onDelete: widget.isAdmin ? () => _delete(b)   : null,
                  );
                },
              ),
            ),
          ),
      ]),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              tooltip: 'Add Book',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Delete "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ),
      );
}