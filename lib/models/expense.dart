class Expense {
  final int? id;
  final int? vehicleId;
  final DateTime date;
  final String category;
  final double amount;
  final String? company;
  final double? liters;
  final double? pricePerLiter;
  final String? receiptPath;
  final String? notes;

  Expense({
    this.id,
    this.vehicleId,
    required this.date,
    required this.category,
    required this.amount,
    this.company,
    this.liters,
    this.pricePerLiter,
    this.receiptPath,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'company': company,
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'receiptPath': receiptPath,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      amount: map['amount'],
      company: map['company'],
      liters: map['liters'],
      pricePerLiter: map['pricePerLiter'],
      receiptPath: map['receiptPath'],
      notes: map['notes'],
    );
  }

  String toCsvRow() {
    return '${date.toIso8601String()},$category,$amount,'
        '"${company ?? ''}",${liters ?? ""},${pricePerLiter ?? ""},'
        '"${receiptPath ?? ''}","${notes ?? ""}"';
  }

  static Expense fromCsvRow(List<dynamic> row) {
    return Expense(
      date: DateTime.parse(row[0].toString()),
      category: row[1].toString(),
      amount: double.parse(row[2].toString()),
      company: row[3].toString().isEmpty ? null : row[3].toString(),
      liters: row[4].toString().isEmpty ? null : double.parse(row[4].toString()),
      pricePerLiter: row[5].toString().isEmpty ? null : double.parse(row[5].toString()),
      receiptPath: row[6].toString().isEmpty ? null : row[6].toString(),
      notes: row[7].toString().isEmpty ? null : row[7].toString(),
    );
  }
}

class ExpenseCategory {
  static const String fuel = 'Polttoaine';
  static const String maintenance = 'Huolto';
  static const String repair = 'Korjaus';
  static const String insurance = 'Vakuutus';
  static const String tax = 'Vero';
  static const String carwash = 'Pesu';
  static const String parts = 'Varaosat';
  static const String tires = 'Renkaat';
  static const String parking = 'Pysäköinti';
  static const String fines = 'Sakot';
  static const String other = 'Muu';

  static List<String> get all => [
    fuel,
    maintenance,
    repair,
    insurance,
    tax,
    carwash,
    parts,
    tires,
    parking,
    fines,
    other,
  ];
}
