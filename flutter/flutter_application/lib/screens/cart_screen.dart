import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onCartChanged;
  const CartScreen({super.key, required this.onCartChanged});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _api = ApiService();
  Cart? _cart;
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
      final cart = await _api.getCart();
      setState(() => _cart = cart);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(int productId) async {
    try {
      final cart = await _api.removeFromCart(productId);
      setState(() => _cart = cart);
      widget.onCartChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: _load, child: const Text('Retry')),
        ]),
      );
    }

    final products = _cart?.products ?? [];

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🛒', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Text(
                      _emojiForType(p.productType),
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(p.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(p.productType),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${p.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => _remove(p.id),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Total footer
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${products.length} item${products.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                'Total:  \$${(_cart?.total ?? 0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _emojiForType(String type) {
    switch (type) {
      case 'BOOK':    return '📚';
      case 'MAGAZINE': return '📰';
      case 'CPU':     return '🖥️';
      case 'GPU':     return '🎮';
      case 'RAM':     return '🧠';
      case 'Drive':   return '💾';
      default:        return '📦';
    }
  }
}
