import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/expense.dart';
import '../config/theme.dart';

class ReceiptViewerPage extends StatelessWidget {
  final Expense expense;

  const ReceiptViewerPage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuitti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (expense.receiptPath != null) {
                Share.shareXFiles([XFile(expense.receiptPath!)]);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Receipt image
          Expanded(
            child: expense.receiptPath != null
                ? InteractiveViewer(
                    child: Center(
                      child: Image.file(
                        File(expense.receiptPath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : const Center(
                    child: Text('Ei kuvaa'),
                  ),
          ),

          // Expense details
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.category,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${expense.amount.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (expense.company != null)
                  Text(
                    'Yritys: ${expense.company}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (expense.liters != null)
                  Text(
                    'Litrat: ${expense.liters!.toStringAsFixed(2)} L',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (expense.pricePerLiter != null)
                  Text(
                    'Hinta/litra: ${expense.pricePerLiter!.toStringAsFixed(3)} €/L',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (expense.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lisätiedot: ${expense.notes}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
