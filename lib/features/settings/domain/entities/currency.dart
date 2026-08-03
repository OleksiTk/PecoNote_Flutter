class Currency {
  const Currency({
    required this.id,
    required this.code,
    required this.symbol,
    required this.name,
  });

  final int id;
  final String code;
  final String symbol;
  final String name;

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
