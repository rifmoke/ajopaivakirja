import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/trip.dart';
import '../models/expense.dart';
import '../models/vehicle.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Initialize FFI for desktop platforms
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ajopaivakirja.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add vehicles table
      await db.execute('''
        CREATE TABLE vehicles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          licensePlate TEXT,
          brand TEXT,
          model TEXT,
          year INTEGER,
          color TEXT,
          createdAt TEXT NOT NULL,
          isActive INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Add reminders table
      await db.execute('''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicleId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          type TEXT NOT NULL,
          trigger TEXT NOT NULL,
          targetDate TEXT,
          targetMileage INTEGER,
          notifyDaysBefore INTEGER,
          notifyMileageBefore INTEGER,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          completedAt TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
        )
      ''');

      // Add vehicleId to trips table
      await db.execute('ALTER TABLE trips ADD COLUMN vehicleId INTEGER');
      
      // Add vehicleId to expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN vehicleId INTEGER');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        licensePlate TEXT,
        brand TEXT,
        model TEXT,
        year INTEGER,
        color TEXT,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        trigger TEXT NOT NULL,
        targetDate TEXT,
        targetMileage INTEGER,
        notifyDaysBefore INTEGER,
        notifyMileageBefore INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    // Trips table
    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT NOT NULL,
        tripType TEXT NOT NULL,
        startOdometer INTEGER NOT NULL,
        endOdometer INTEGER NOT NULL,
        startAddress TEXT,
        endAddress TEXT,
        startLat REAL,
        startLon REAL,
        endLat REAL,
        endLon REAL,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE SET NULL
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        company TEXT,
        liters REAL,
        pricePerLiter REAL,
        receiptPath TEXT,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE SET NULL
      )
    ''');
  }

  // Trip CRUD operations
  Future<int> insertTrip(Trip trip) async {
    final db = await database;
    return await db.insert('trips', trip.toMap());
  }

  Future<List<Trip>> getAllTrips() async {
    final db = await database;
    final maps = await db.query('trips', orderBy: 'date DESC');
    return maps.map((map) => Trip.fromMap(map)).toList();
  }

  Future<List<Trip>> getTripsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'trips',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Trip.fromMap(map)).toList();
  }

  Future<int> updateTrip(Trip trip) async {
    final db = await database;
    return await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<int> deleteTrip(int id) async {
    final db = await database;
    return await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTrips() async {
    final db = await database;
    return await db.delete('trips');
  }

  // Expense CRUD operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllExpenses() async {
    final db = await database;
    return await db.delete('expenses');
  }

  // Vehicle CRUD operations
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final maps = await db.query('vehicles', orderBy: 'createdAt DESC');
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<Vehicle?> getVehicle(int id) async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reminder CRUD operations
  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final maps = await db.query('reminders', orderBy: 'createdAt DESC');
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getRemindersForVehicle(int vehicleId) async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'vehicleId = ? AND isCompleted = 0',
      whereArgs: [vehicleId],
      orderBy: 'targetDate ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get trips for specific vehicle
  Future<List<Trip>> getTripsForVehicle(int? vehicleId) async {
    final db = await database;
    if (vehicleId == null) {
      final maps = await db.query('trips', where: 'vehicleId IS NULL', orderBy: 'date DESC');
      return maps.map((map) => Trip.fromMap(map)).toList();
    }
    final maps = await db.query(
      'trips',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Trip.fromMap(map)).toList();
  }

  // Get expenses for specific vehicle
  Future<List<Expense>> getExpensesForVehicle(int? vehicleId) async {
    final db = await database;
    if (vehicleId == null) {
      final maps = await db.query('expenses', where: 'vehicleId IS NULL', orderBy: 'date DESC');
      return maps.map((map) => Expense.fromMap(map)).toList();
    }
    final maps = await db.query(
      'expenses',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
