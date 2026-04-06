import 'package:flutter/material.dart';
import '../models/magazine.dart';
import '../services/api_service.dart';
import '../widgets/product_tile.dart';
import '../widgets/search_bar_field.dart';
import 'admin/magazine_form_screen.dart';

class MagazinesScreen extends StatefulWidget {
  final VoidCallback onCartChanged;
  final bool isAdmin;
  const MagazinesScreen({super.key, required this.onCartChanged, required this.isAdmin});

  @override
  State<MagazinesScreen> createState() => _MagazinesScreenState();
}

class _MagazinesScreenState extends State<MagazinesScreen> {
  final _api        = ApiService();
  final _searchCtrl = TextEditingController();
  List<Magazine> _all   = [];
  List<Magazine> _shown = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final mags = await _api.getMagazines();
      if (!mounted) return;
      setState(() { _all = mags; _filter(_searchCtrl.text); });
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
          : _all.where((m) => m.title.toLowerCase().contains(lower)).toList();
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

  Future<void> _openForm([Magazine? mag]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MagazineFormScreen(magazine: mag)),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(Magazine mag) async {
    final confirmed = await _confirmDelete(context, mag.title);
    if (!confirmed) return;
    try {
      await _api.deleteMagazine(mag.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  String _formatIssue(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorRetry(message: _error!, onRetry: _load);

    return Scaffold(
      body: Column(children: [
        SearchBarField(
          controller: _searchCtrl,
          hint: 'Search magazines…',
          onChanged: _filter,
        ),
        if (_shown.isEmpty)
          const Expanded(child: Center(child: Text('No magazines match.')))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _shown.length,
                itemBuilder: (_, i) {
                  final m = _shown[i];
                  final issue = _formatIssue(m.currentIssue);
                  return ProductTile(
                    emoji: '📰',
                    title: m.title,
                    subtitle: issue.isNotEmpty
                        ? 'Issue: $issue · ${m.copies} copies'
                        : '${m.copies} copies',
                    price: '\$${m.price.toStringAsFixed(2)}',
                    onAddToCart: () => _addToCart(m.id),
                    onEdit:   widget.isAdmin ? () => _openForm(m) : null,
                    onDelete: widget.isAdmin ? () => _delete(m)   : null,
                  );
                },
              ),
            ),
          ),
      ]),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              tooltip: 'Add Magazine',
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

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}