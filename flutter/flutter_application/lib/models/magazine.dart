class Magazine {
  final int id;
  final String title;
  final double price;
  final int copies;
  final int orderQty;
  final String? currentIssue;

  Magazine({
    required this.id,
    required this.title,
    required this.price,
    required this.copies,
    required this.orderQty,
    this.currentIssue,
  });

  factory Magazine.fromJson(Map<String, dynamic> j) => Magazine(
        id:           j['id'] as int,
        title:        j['title'] as String? ?? '',
        price:        (j['price'] as num?)?.toDouble() ?? 0.0,
        copies:       j['copies'] as int? ?? 0,
        orderQty:     j['orderQty'] as int? ?? 0,
        currentIssue: j['currentIssue'] as String?,
      );
}
