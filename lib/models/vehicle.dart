class Vehicle {
  final int? id;
  final String name;
  final String? licensePlate;
  final String? brand;
  final String? model;
  final int? year;
  final String? color;
  final DateTime createdAt;
  final bool isActive;

  Vehicle({
    this.id,
    required this.name,
    this.licensePlate,
    this.brand,
    this.model,
    this.year,
    this.color,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      name: map['name'] as String,
      licensePlate: map['licensePlate'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      year: map['year'] as int?,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }

  Vehicle copyWith({
    int? id,
    String? name,
    String? licensePlate,
    String? brand,
    String? model,
    int? year,
    String? color,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
