import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'books_screen.dart';
import 'magazines_screen.dart';
import 'hardware_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _api     = ApiService();
  int  _currentIndex = 0;
  int  _cartCount    = 0;
  bool _isAdmin      = false;
  bool _resolving    = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Resolve both admin status and cart count in parallel
    final results = await Future.wait([
      _api.isAdmin(),
      _api.getCart().then((c) => c.products.length).catchError((_) => 0),
    ]);
    if (!mounted) return;
    setState(() {
      _isAdmin   = results[0] as bool;
      _cartCount = results[1] as int;
      _resolving = false;
    });
  }

  void _refreshCartCount() async {
    try {
      final cart = await _api.getCart();
      if (mounted) setState(() => _cartCount = cart.products.length);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      BooksScreen(onCartChanged: _refreshCartCount, isAdmin: _isAdmin),
      MagazinesScreen(onCartChanged: _refreshCartCount, isAdmin: _isAdmin),
      HardwareScreen(onCartChanged: _refreshCartCount, isAdmin: _isAdmin),
      CartScreen(onCartChanged: _refreshCartCount),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Bookstore'),
          if (_isAdmin) ...[
            const SizedBox(width: 8),
            Chip(
              label: const Text('ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await _api.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          const NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Magazines',
          ),
          const NavigationDestination(
            icon: Icon(Icons.computer_outlined),
            selectedIcon: Icon(Icons.computer),
            label: 'Hardware',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}