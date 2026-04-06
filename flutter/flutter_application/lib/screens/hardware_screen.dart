import 'package:flutter/material.dart';
import '../models/hardware.dart';
import '../services/api_service.dart';
import '../widgets/product_tile.dart';
import '../widgets/search_bar_field.dart';
import 'admin/hardware_form_screen.dart';

class HardwareScreen extends StatefulWidget {
  final VoidCallback onCartChanged;
  final bool isAdmin;
  const HardwareScreen({super.key, required this.onCartChanged, required this.isAdmin});

  @override
  State<HardwareScreen> createState() => _HardwareScreenState();
}

class _HardwareScreenState extends State<HardwareScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;

  final List<List<HardwareProduct>> _all   = [[], [], [], []];
  final List<List<HardwareProduct>> _shown = [[], [], [], []];
  final List<TextEditingController> _searches =
      List.generate(4, (_) => TextEditingController());
  final List<bool>    _loading = [true, true, true, true];
  final List<String?> _errors  = [null, null, null, null];

  static const _tabs  = ['CPUs', 'GPUs', 'RAM', 'Drives'];
  static const _types = ['CPU',  'GPU',  'RAM', 'Drive'];
  static const _emojis = ['🖥️', '🎮', '🧠', '💾'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _searches) c.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_load(0), _load(1), _load(2), _load(3)]);
  }

  Future<void> _load(int tab) async {
    setState(() { _loading[tab] = true; _errors[tab] = null; });
    try {
      final List<HardwareProduct> data;
      switch (tab) {
        case 0: data = await _api.getCpus();   break;
        case 1: data = await _api.getGpus();   break;
        case 2: data = await _api.getRam();    break;
        case 3: data = await _api.getDrives(); break;
        default: data = [];
      }
      if (!mounted) return;
      setState(() {
        _all[tab]   = data;
        _filter(tab, _searches[tab].text);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errors[tab] = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading[tab] = false);
    }
  }

  void _filter(int tab, String q) {
    final lower = q.toLowerCase();
    setState(() {
      _shown[tab] = q.isEmpty
          ? List.from(_all[tab])
          : _all[tab].where((h) =>
              h.name.toLowerCase().contains(lower) ||
              h.manufacturer.toLowerCase().contains(lower) ||
              (h.generation?.toLowerCase().contains(lower) ?? false) ||
              (h.driveType?.toLowerCase().contains(lower) ?? false)).toList();
    });
  }

  Future<void> _addToCart(int productId) async {
    try {
      await _api.addToCart(productId);
      widget.onCartChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openForm(int tab, [HardwareProduct? product]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HardwareFormScreen(
          productType: _types[tab],
          product: product,
        ),
      ),
    );
    if (changed == true) _load(tab);
  }

  Future<void> _delete(int tab, HardwareProduct product) async {
    final confirmed = await _confirmDelete(context, '${product.manufacturer} ${product.name}');
    if (!confirmed) return;
    try {
      switch (tab) {
        case 0: await _api.deleteCpu(product.id);   break;
        case 1: await _api.deleteGpu(product.id);   break;
        case 2: await _api.deleteRam(product.id);   break;
        case 3: await _api.deleteDrive(product.id); break;
      }
      _load(tab);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    }
  }

  Widget _buildTab(int tab) {
    if (_loading[tab]) return const Center(child: CircularProgressIndicator());
    if (_errors[tab] != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        Text(_errors[tab]!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => _load(tab), child: const Text('Retry')),
      ]));
    }

    return Scaffold(
      body: Column(children: [
        SearchBarField(
          controller: _searches[tab],
          hint: 'Search ${_tabs[tab].toLowerCase()}…',
          onChanged: (q) => _filter(tab, q),
        ),
        if (_shown[tab].isEmpty)
          const Expanded(child: Center(child: Text('No results.')))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(tab),
              child: ListView.builder(
                itemCount: _shown[tab].length,
                itemBuilder: (_, i) {
                  final h = _shown[tab][i];
                  return ProductTile(
                    emoji: _emojis[tab],
                    title: '${h.manufacturer} ${h.name}',
                    subtitle: h.subtitle,
                    price: '\$${h.price.toStringAsFixed(2)}',
                    onAddToCart: () => _addToCart(h.id),
                    onEdit:   widget.isAdmin ? () => _openForm(tab, h) : null,
                    onDelete: widget.isAdmin ? () => _delete(tab, h)   : null,
                  );
                },
              ),
            ),
          ),
      ]),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => _openForm(tab),
              tooltip: 'Add ${_types[tab]}',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TabBar(
        controller: _tabController,
        tabs: _tabs.asMap().entries.map((e) =>
            Tab(text: '${_emojis[e.key]} ${e.value}')).toList(),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: List.generate(4, _buildTab),
        ),
      ),
    ]);
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