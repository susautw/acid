class AccountingTransaction {
  final int? id;
  final String date;
  final String description;
  final double amount;
  final String type;

  AccountingTransaction({this.id, required this.date, required this.description, required this.amount, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'amount': amount,
      'type': type,
    };
  }
}
