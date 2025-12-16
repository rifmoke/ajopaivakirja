class Trip {
  final int? id;
  final int? vehicleId;
  final DateTime date;
  final String tripType; // 'work' tai 'private'
  final int startOdometer;
  final int endOdometer;
  final String? startAddress;
  final String? endAddress;
  final double? startLat;
  final double? startLon;
  final double? endLat;
  final double? endLon;
  final String? notes;

  Trip({
    this.id,
    this.vehicleId,
    required this.date,
    required this.tripType,
    required this.startOdometer,
    required this.endOdometer,
    this.startAddress,
    this.endAddress,
    this.startLat,
    this.startLon,
    this.endLat,
    this.endLon,
    this.notes,
  });

  int get distance => endOdometer - startOdometer;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'tripType': tripType,
      'startOdometer': startOdometer,
      'endOdometer': endOdometer,
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startLat': startLat,
      'startLon': startLon,
      'endLat': endLat,
      'endLon': endLon,
      'notes': notes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: DateTime.parse(map['date']),
      tripType: map['tripType'],
      startOdometer: map['startOdometer'],
      endOdometer: map['endOdometer'],
      startAddress: map['startAddress'],
      endAddress: map['endAddress'],
      startLat: map['startLat'],
      startLon: map['startLon'],
      endLat: map['endLat'],
      endLon: map['endLon'],
      notes: map['notes'],
    );
  }

  String toCsvRow() {
    return '${date.toIso8601String()},$tripType,$startOdometer,$endOdometer,'
        '"${startAddress ?? ''}","${endAddress ?? ''}",'
        '${startLat ?? ""},${startLon ?? ""},${endLat ?? ""},${endLon ?? ""},"${notes ?? ""}"';
  }

  static Trip fromCsvRow(List<dynamic> row) {
    return Trip(
      date: DateTime.parse(row[0].toString()),
      tripType: row[1].toString(),
      startOdometer: int.parse(row[2].toString()),
      endOdometer: int.parse(row[3].toString()),
      startAddress: row[4].toString().isEmpty ? null : row[4].toString(),
      endAddress: row[5].toString().isEmpty ? null : row[5].toString(),
      startLat: row[6].toString().isEmpty ? null : double.parse(row[6].toString()),
      startLon: row[7].toString().isEmpty ? null : double.parse(row[7].toString()),
      endLat: row[8].toString().isEmpty ? null : double.parse(row[8].toString()),
      endLon: row[9].toString().isEmpty ? null : double.parse(row[9].toString()),
      notes: row[10].toString().isEmpty ? null : row[10].toString(),
    );
  }
}
