class PaymentPerformanceModel {
  final String date;
  final int qty;
  final double totalAmount;

  PaymentPerformanceModel({
    required this.date,
    required this.qty,
    required this.totalAmount,
  });

  factory PaymentPerformanceModel.fromJson(Map<String, dynamic> json) {
    return PaymentPerformanceModel(
      date: json['date'] ?? '',
      qty: json['qty'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
}
