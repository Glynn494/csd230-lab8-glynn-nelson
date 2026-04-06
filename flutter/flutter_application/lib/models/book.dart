class Book {
  final int id;
  final String title;
  final String author;
  final double price;
  final int copies;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.copies,
  });

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        id:     j['id'] as int,
        title:  j['title'] as String? ?? '',
        author: j['author'] as String? ?? '',
        price:  (j['price'] as num?)?.toDouble() ?? 0.0,
        copies: j['copies'] as int? ?? 0,
      );
}
