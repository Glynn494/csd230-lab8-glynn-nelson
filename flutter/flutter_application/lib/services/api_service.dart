import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/book.dart';
import '../models/magazine.dart';
import '../models/hardware.dart';
import '../models/cart.dart';

class ApiService {
  // ── Token storage ────────────────────────────────────────────────
  static const _tokenKey = 'jwt_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Admin check ──────────────────────────────────────────────────
  /// Decodes the stored JWT and returns true if the user has ROLE_ADMIN.
  Future<bool> isAdmin() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      // Base64url → base64 padding
      String base64 = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (base64.length % 4 != 0) base64 += '=';
      final payload = jsonDecode(utf8.decode(base64Decode(base64))) as Map<String, dynamic>;
      final roles = payload['roles'] as List<dynamic>? ?? [];
      return roles.contains('ROLE_ADMIN');
    } catch (_) {
      return false;
    }
  }

  // ── Auth headers ─────────────────────────────────────────────────
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ─────────────────────────────────────────────────────────
  Future<String> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      await saveToken(token);
      return token;
    }
    throw Exception('Invalid username or password');
  }

  Future<void> logout() => clearToken();

  // ── Books ─────────────────────────────────────────────────────────
  Future<List<Book>> getBooks() async {
    final res = await http.get(Uri.parse('$kBaseUrl/books'), headers: await _headers());
    _checkStatus(res);
    return (jsonDecode(res.body) as List).map((j) => Book.fromJson(j)).toList();
  }

  Future<Book> createBook(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/books'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return Book.fromJson(jsonDecode(res.body));
  }

  Future<Book> updateBook(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/books/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return Book.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteBook(int id) async {
    final res = await http.delete(Uri.parse('$kBaseUrl/books/$id'), headers: await _headers());
    _checkStatus(res);
  }

  // ── Magazines ─────────────────────────────────────────────────────
  Future<List<Magazine>> getMagazines() async {
    final res = await http.get(Uri.parse('$kBaseUrl/magazines'), headers: await _headers());
    _checkStatus(res);
    return (jsonDecode(res.body) as List).map((j) => Magazine.fromJson(j)).toList();
  }

  Future<Magazine> createMagazine(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/magazines'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return Magazine.fromJson(jsonDecode(res.body));
  }

  Future<Magazine> updateMagazine(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/magazines/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return Magazine.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteMagazine(int id) async {
    final res = await http.delete(Uri.parse('$kBaseUrl/magazines/$id'), headers: await _headers());
    _checkStatus(res);
  }

  // ── Hardware helpers ──────────────────────────────────────────────
  Future<List<HardwareProduct>> _getHardware(String endpoint) async {
    final res = await http.get(Uri.parse('$kBaseUrl/$endpoint'), headers: await _headers());
    _checkStatus(res);
    return (jsonDecode(res.body) as List).map((j) => HardwareProduct.fromJson(j)).toList();
  }

  Future<HardwareProduct> _createHardware(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return HardwareProduct.fromJson(jsonDecode(res.body));
  }

  Future<HardwareProduct> _updateHardware(String endpoint, int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/$endpoint/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(res);
    return HardwareProduct.fromJson(jsonDecode(res.body));
  }

  Future<void> _deleteHardware(String endpoint, int id) async {
    final res = await http.delete(Uri.parse('$kBaseUrl/$endpoint/$id'), headers: await _headers());
    _checkStatus(res);
  }

  Future<List<HardwareProduct>> getCpus()   => _getHardware('cpus');
  Future<List<HardwareProduct>> getGpus()   => _getHardware('gpus');
  Future<List<HardwareProduct>> getRam()    => _getHardware('ram');
  Future<List<HardwareProduct>> getDrives() => _getHardware('drives');

  Future<HardwareProduct> createCpu(Map<String, dynamic> b)   => _createHardware('cpus', b);
  Future<HardwareProduct> createGpu(Map<String, dynamic> b)   => _createHardware('gpus', b);
  Future<HardwareProduct> createRam(Map<String, dynamic> b)   => _createHardware('ram', b);
  Future<HardwareProduct> createDrive(Map<String, dynamic> b) => _createHardware('drives', b);

  Future<HardwareProduct> updateCpu(int id, Map<String, dynamic> b)   => _updateHardware('cpus', id, b);
  Future<HardwareProduct> updateGpu(int id, Map<String, dynamic> b)   => _updateHardware('gpus', id, b);
  Future<HardwareProduct> updateRam(int id, Map<String, dynamic> b)   => _updateHardware('ram', id, b);
  Future<HardwareProduct> updateDrive(int id, Map<String, dynamic> b) => _updateHardware('drives', id, b);

  Future<void> deleteCpu(int id)   => _deleteHardware('cpus', id);
  Future<void> deleteGpu(int id)   => _deleteHardware('gpus', id);
  Future<void> deleteRam(int id)   => _deleteHardware('ram', id);
  Future<void> deleteDrive(int id) => _deleteHardware('drives', id);

  // ── Cart ──────────────────────────────────────────────────────────
  Future<Cart> getCart() async {
    final res = await http.get(Uri.parse('$kBaseUrl/cart'), headers: await _headers());
    _checkStatus(res);
    return Cart.fromJson(jsonDecode(res.body));
  }

  Future<Cart> addToCart(int productId) async {
    final res = await http.post(Uri.parse('$kBaseUrl/cart/add/$productId'), headers: await _headers());
    _checkStatus(res);
    return Cart.fromJson(jsonDecode(res.body));
  }

  Future<Cart> removeFromCart(int productId) async {
    final res = await http.delete(Uri.parse('$kBaseUrl/cart/remove/$productId'), headers: await _headers());
    _checkStatus(res);
    return Cart.fromJson(jsonDecode(res.body));
  }

  // ── Status check ──────────────────────────────────────────────────
  void _checkStatus(http.Response res) {
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Unauthorized — please log in again');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }
  }
}