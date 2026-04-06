import 'package:flutter/material.dart';
import '../../../models/book.dart';
import '../../../services/api_service.dart';

class BookFormScreen extends StatefulWidget {
  /// Pass an existing book to edit it, or null to create a new one.
  final Book? book;
  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _api       = ApiService();
  final _formKey   = GlobalKey<FormState>();
  bool _saving     = false;

  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _price;
  late final TextEditingController _copies;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    _title  = TextEditingController(text: widget.book?.title  ?? '');
    _author = TextEditingController(text: widget.book?.author ?? '');
    _price  = TextEditingController(text: widget.book != null ? widget.book!.price.toString()  : '');
    _copies = TextEditingController(text: widget.book != null ? widget.book!.copies.toString() : '10');
  }

  @override
  void dispose() {
    _title.dispose(); _author.dispose(); _price.dispose(); _copies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'title':  _title.text.trim(),
      'author': _author.text.trim(),
      'price':  double.parse(_price.text.trim()),
      'copies': int.parse(_copies.text.trim()),
    };
    try {
      if (_isEditing) {
        await _api.updateBook(widget.book!.id, body);
      } else {
        await _api.createBook(body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true); // true = list needs refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Book' : 'Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field(_title,  'Title',        isRequired: true),
            _field(_author, 'Author',       isRequired: true),
            _field(_price,  'Price',        isRequired: true, isDecimal: true),
            _field(_copies, 'Copies',       isRequired: true, isInt: true),
            const SizedBox(height: 24),
            _saveButton(),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool isRequired = false, bool isDecimal = false, bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : isInt ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) {
          if (isRequired && (v == null || v.trim().isEmpty)) return 'Required';
          if (isDecimal && double.tryParse(v ?? '') == null) return 'Enter a valid number';
          if (isInt    && int.tryParse(v ?? '')    == null) return 'Enter a whole number';
          return null;
        },
      ),
    );
  }

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save Changes' : 'Add Book'),
        ),
      );
}
