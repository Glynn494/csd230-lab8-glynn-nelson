import 'package:flutter/material.dart';
import '../../../models/hardware.dart';
import '../../../services/api_service.dart';

/// A single form screen used for all four hardware types.
/// Pass [productType] as one of: 'CPU', 'GPU', 'RAM', 'Drive'
/// Pass [product] to edit an existing item, or null to create new.
class HardwareFormScreen extends StatefulWidget {
  final String productType;
  final HardwareProduct? product;

  const HardwareFormScreen({
    super.key,
    required this.productType,
    this.product,
  });

  @override
  State<HardwareFormScreen> createState() => _HardwareFormScreenState();
}

class _HardwareFormScreenState extends State<HardwareFormScreen> {
  final _api     = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _saving   = false;

  // Common fields
  late final TextEditingController _name;
  late final TextEditingController _manufacturer;
  late final TextEditingController _price;
  late final TextEditingController _warranty;

  // CPU
  late final TextEditingController _cores;

  // GPU
  late final TextEditingController _vram;

  // RAM
  late final TextEditingController _capacity;
  String _generation = 'DDR5';
  late final TextEditingController _speed;

  // Drive
  late final TextEditingController _storage;
  String _driveType = 'SSD';
  late final TextEditingController _readSpeed;
  late final TextEditingController _writeSpeed;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name         = TextEditingController(text: p?.name         ?? '');
    _manufacturer = TextEditingController(text: p?.manufacturer ?? '');
    _price        = TextEditingController(text: p != null ? p.price.toString()          : '');
    _warranty     = TextEditingController(text: p != null ? p.warrantyMonths.toString() : '36');
    _cores        = TextEditingController(text: p?.cores?.toString()         ?? '8');
    _vram         = TextEditingController(text: p?.vramGB?.toString()        ?? '8');
    _capacity     = TextEditingController(text: p?.capacityGB?.toString()    ?? '16');
    _speed        = TextEditingController(text: p?.speedMHz?.toString()      ?? '6000');
    _storage      = TextEditingController(text: p?.storageGB?.toString()     ?? '1000');
    _readSpeed    = TextEditingController(text: p?.readSpeedMBs?.toString()  ?? '3500');
    _writeSpeed   = TextEditingController(text: p?.writeSpeedMBs?.toString() ?? '3000');
    if (p?.generation != null) _generation = p!.generation!;
    if (p?.driveType  != null) _driveType  = p!.driveType!;
  }

  @override
  void dispose() {
    for (final c in [_name, _manufacturer, _price, _warranty,
                     _cores, _vram, _capacity, _speed,
                     _storage, _readSpeed, _writeSpeed]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final base = {
      'name':           _name.text.trim(),
      'manufacturer':   _manufacturer.text.trim(),
      'price':          double.parse(_price.text.trim()),
      'warrantyMonths': int.parse(_warranty.text.trim()),
    };

    Map<String, dynamic> body;
    switch (widget.productType) {
      case 'CPU':
        body = {...base, 'cores': int.parse(_cores.text.trim())};
        break;
      case 'GPU':
        body = {...base, 'vramGB': int.parse(_vram.text.trim())};
        break;
      case 'RAM':
        body = {
          ...base,
          'capacityGB': int.parse(_capacity.text.trim()),
          'generation': _generation,
          'speedMHz':   int.parse(_speed.text.trim()),
        };
        break;
      case 'Drive':
        body = {
          ...base,
          'storageGB':     int.parse(_storage.text.trim()),
          'driveType':     _driveType,
          'readSpeedMBs':  int.parse(_readSpeed.text.trim()),
          'writeSpeedMBs': int.parse(_writeSpeed.text.trim()),
        };
        break;
      default:
        body = base;
    }

    try {
      if (_isEditing) {
        switch (widget.productType) {
          case 'CPU':   await _api.updateCpu(widget.product!.id, body);   break;
          case 'GPU':   await _api.updateGpu(widget.product!.id, body);   break;
          case 'RAM':   await _api.updateRam(widget.product!.id, body);   break;
          case 'Drive': await _api.updateDrive(widget.product!.id, body); break;
        }
      } else {
        switch (widget.productType) {
          case 'CPU':   await _api.createCpu(body);   break;
          case 'GPU':   await _api.createGpu(body);   break;
          case 'RAM':   await _api.createRam(body);   break;
          case 'Drive': await _api.createDrive(body); break;
        }
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
    final action = _isEditing ? 'Edit' : 'Add';
    return Scaffold(
      appBar: AppBar(title: Text('$action ${widget.productType}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Common fields
            _field(_name,         'Name',              isRequired: true),
            _field(_manufacturer, 'Manufacturer',      isRequired: true),
            _field(_price,        'Price',             isRequired: true, isDecimal: true),
            _field(_warranty,     'Warranty (months)', isRequired: true, isInt: true),
            const Divider(height: 32),
            // Type-specific fields
            ..._typeFields(),
            const SizedBox(height: 24),
            _saveButton(action),
          ]),
        ),
      ),
    );
  }

  List<Widget> _typeFields() {
    switch (widget.productType) {
      case 'CPU':
        return [_field(_cores, 'Cores', isRequired: true, isInt: true)];

      case 'GPU':
        return [_field(_vram, 'VRAM (GB)', isRequired: true, isInt: true)];

      case 'RAM':
        return [
          _field(_capacity, 'Capacity (GB)', isRequired: true, isInt: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _generation,
              decoration: const InputDecoration(labelText: 'Generation', border: OutlineInputBorder()),
              items: ['DDR5', 'DDR4', 'DDR3']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _generation = v!),
            ),
          ),
          _field(_speed, 'Speed (MHz)', isRequired: true, isInt: true),
        ];

      case 'Drive':
        return [
          _field(_storage, 'Storage (GB)', isRequired: true, isInt: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _driveType,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: ['SSD', 'HDD']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _driveType = v!),
            ),
          ),
          _field(_readSpeed,  'Read Speed (MB/s)',  isRequired: true, isInt: true),
          _field(_writeSpeed, 'Write Speed (MB/s)', isRequired: true, isInt: true),
        ];

      default:
        return [];
    }
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

  Widget _saveButton(String action) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Save Changes' : 'Add ${widget.productType}'),
        ),
      );
}
