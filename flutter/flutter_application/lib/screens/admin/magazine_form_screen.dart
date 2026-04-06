import 'package:flutter/material.dart';
import '../../../models/magazine.dart';
import '../../../services/api_service.dart';

class MagazineFormScreen extends StatefulWidget {
  final Magazine? magazine;
  const MagazineFormScreen({super.key, this.magazine});

  @override
  State<MagazineFormScreen> createState() => _MagazineFormScreenState();
}

class _MagazineFormScreenState extends State<MagazineFormScreen> {
  final _api     = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _saving   = false;

  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _copies;
  late final TextEditingController _orderQty;
  DateTime? _issueDate;

  bool get _isEditing => widget.magazine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.magazine;
    _title    = TextEditingController(text: m?.title    ?? '');
    _price    = TextEditingController(text: m != null ? m.price.toString()    : '');
    _copies   = TextEditingController(text: m != null ? m.copies.toString()   : '10');
    _orderQty = TextEditingController(text: m != null ? m.orderQty.toString() : '100');
    if (m?.currentIssue != null) {
      try { _issueDate = DateTime.parse(m!.currentIssue!); } catch (_) {}
    }
  }

  @override
  void dispose() {
    _title.dispose(); _price.dispose(); _copies.dispose(); _orderQty.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue date')));
      return;
    }
    setState(() => _saving = true);
    // Backend expects "yyyy-MM-ddTHH:mm:ss"
    final issueStr =
        '${_issueDate!.year.toString().padLeft(4,'0')}-'
        '${_issueDate!.month.toString().padLeft(2,'0')}-'
        '${_issueDate!.day.toString().padLeft(2,'0')}T00:00:00';
    final body = {
      'title':        _title.text.trim(),
      'price':        double.parse(_price.text.trim()),
      'copies':       int.parse(_copies.text.trim()),
      'orderQty':     int.parse(_orderQty.text.trim()),
      'currentIssue': issueStr,
    };
    try {
      if (_isEditing) {
        await _api.updateMagazine(widget.magazine!.id, body);
      } else {
        await _api.createMagazine(body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final dateLabel = _issueDate != null
        ? '${_issueDate!.year}-${_issueDate!.month.toString().padLeft(2,'0')}-${_issueDate!.day.toString().padLeft(2,'0')}'
        : 'Tap to select date';

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Magazine' : 'Add Magazine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field(_title,    'Title',       isRequired: true),
            _field(_price,    'Price',       isRequired: true, isDecimal: true),
            _field(_copies,   'Copies',      isRequired: true, isInt: true),
            _field(_orderQty, 'Order Qty',   isRequired: true, isInt: true),
            // Date picker
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Issue Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(dateLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _issueDate == null
                                ? Theme.of(context).hintColor
                                : null,
                          )),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
              : Text(_isEditing ? 'Save Changes' : 'Add Magazine'),
        ),
      );
}
