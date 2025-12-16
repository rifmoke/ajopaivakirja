import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../config/theme.dart';
import 'add_expense_page.dart';
import 'receipt_viewer_page.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kululista'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text('Ei kuluja'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return _ExpenseListItem(
                  expense: expense,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpensePage(expense: expense),
                      ),
                    );
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Poista kulu'),
                        content: const Text('Haluatko varmasti poistaa tämän kulun?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Peruuta'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Poista'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && expense.id != null) {
                      await context.read<ExpenseProvider>().deleteExpense(expense.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kulu poistettu')),
                        );
                      }
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpensePage()),
          );
        },
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExpenseListItem({
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Receipt thumbnail or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: expense.receiptPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(expense.receiptPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.receipt, size: 32);
                          },
                        ),
                      )
                    : const Icon(Icons.receipt, size: 32),
              ),
              const SizedBox(width: 12),

              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (expense.company != null)
                      Text(
                        expense.company!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      dateFormat.format(expense.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (expense.liters != null)
                      Text(
                        '${expense.liters!.toStringAsFixed(2)} L @ ${expense.pricePerLiter?.toStringAsFixed(2) ?? "?"} €/L',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryRed,
                        ),
                      ),
                  ],
                ),
              ),

              // Amount and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${expense.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (expense.receiptPath != null)
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceiptViewerPage(expense: expense),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
