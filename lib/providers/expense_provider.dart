import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await DatabaseHelper.instance.getAllExpenses();
    } catch (e) {
      print('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.insertExpense(expense);
      await loadExpenses();
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DatabaseHelper.instance.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  Future<void> deleteAllExpenses() async {
    try {
      await DatabaseHelper.instance.deleteAllExpenses();
      await loadExpenses();
    } catch (e) {
      print('Error deleting all expenses: $e');
    }
  }

  // Statistics
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get monthExpenses {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _expenses
        .where((expense) => expense.date.isAfter(monthStart) && expense.date.isBefore(monthEnd))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryExpenses() {
    Map<String, double> categoryTotals = {};
    
    for (var category in ExpenseCategory.all) {
      final total = _expenses
          .where((expense) => expense.category == category)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      if (total > 0) {
        categoryTotals[category] = total;
      }
    }
    
    return categoryTotals;
  }

  Map<int, double> getMonthlyExpenses() {
    final now = DateTime.now();
    Map<int, double> monthlyData = {};
    
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      
      final monthTotal = _expenses
          .where((expense) => 
              expense.date.isAfter(month) && 
              expense.date.isBefore(monthEnd.add(const Duration(days: 1))))
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      monthlyData[month.month] = monthTotal;
    }
    
    return monthlyData;
  }

  // Fuel statistics
  List<Expense> get fuelExpenses {
    return _expenses.where((e) => e.category == ExpenseCategory.fuel).toList();
  }

  int get fuelCount {
    return fuelExpenses.length;
  }

  double get totalLiters {
    return fuelExpenses
        .where((e) => e.liters != null)
        .fold(0.0, (sum, expense) => sum + (expense.liters ?? 0));
  }

  double get averagePricePerLiter {
    final fuelWithPrice = fuelExpenses.where((e) => e.pricePerLiter != null).toList();
    if (fuelWithPrice.isEmpty) return 0;
    
    final total = fuelWithPrice.fold(0.0, (sum, e) => sum + (e.pricePerLiter ?? 0));
    return total / fuelWithPrice.length;
  }
}
