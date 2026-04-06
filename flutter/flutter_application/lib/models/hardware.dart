class HardwareProduct {
  final int id;
  final String productType; // "CPU" | "GPU" | "RAM" | "Drive"
  final String name;
  final String manufacturer;
  final double price;
  final int warrantyMonths;

  // CPU
  final int? cores;

  // GPU
  final int? vramGB;

  // RAM
  final int? capacityGB;
  final String? generation;
  final int? speedMHz;

  // Drive
  final int? storageGB;
  final String? driveType;
  final int? readSpeedMBs;
  final int? writeSpeedMBs;

  HardwareProduct({
    required this.id,
    required this.productType,
    required this.name,
    required this.manufacturer,
    required this.price,
    required this.warrantyMonths,
    this.cores,
    this.vramGB,
    this.capacityGB,
    this.generation,
    this.speedMHz,
    this.storageGB,
    this.driveType,
    this.readSpeedMBs,
    this.writeSpeedMBs,
  });

  factory HardwareProduct.fromJson(Map<String, dynamic> j) => HardwareProduct(
        id:             j['id'] as int,
        productType:    j['productType'] as String? ?? 'Hardware',
        name:           j['name'] as String? ?? '',
        manufacturer:   j['manufacturer'] as String? ?? '',
        price:          (j['price'] as num?)?.toDouble() ?? 0.0,
        warrantyMonths: j['warrantyMonths'] as int? ?? 0,
        cores:          j['cores'] as int?,
        vramGB:         j['vramGB'] as int?,
        capacityGB:     j['capacityGB'] as int?,
        generation:     j['generation'] as String?,
        speedMHz:       j['speedMHz'] as int?,
        storageGB:      j['storageGB'] as int?,
        driveType:      j['driveType'] as String?,
        readSpeedMBs:   j['readSpeedMBs'] as int?,
        writeSpeedMBs:  j['writeSpeedMBs'] as int?,
      );

  /// Human-readable subtitle line for list tiles
  String get subtitle {
    switch (productType) {
      case 'CPU':
        return '$cores cores · ${warrantyMonths}mo warranty · \$${price.toStringAsFixed(2)}';
      case 'GPU':
        return '${vramGB}GB VRAM · ${warrantyMonths}mo warranty · \$${price.toStringAsFixed(2)}';
      case 'RAM':
        return '${capacityGB}GB $generation ${speedMHz}MHz · \$${price.toStringAsFixed(2)}';
      case 'Drive':
        final storage = (storageGB ?? 0) >= 1000
            ? '${((storageGB ?? 0) / 1000).toStringAsFixed(0)} TB'
            : '${storageGB} GB';
        return '$storage $driveType · R:${readSpeedMBs} W:${writeSpeedMBs} MB/s · \$${price.toStringAsFixed(2)}';
      default:
        return '\$${price.toStringAsFixed(2)}';
    }
  }
}
