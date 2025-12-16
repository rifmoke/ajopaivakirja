import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../config/theme.dart';
import 'expense_list_page.dart';
import 'add_expense_page.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpenseOverviewPage();
  }
}

class ExpenseOverviewPage extends StatefulWidget {
  const ExpenseOverviewPage({super.key});

  @override
  State<ExpenseOverviewPage> createState() => _ExpenseOverviewPageState();
}

class _ExpenseOverviewPageState extends State<ExpenseOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kulut'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalExpenses(context),
            const SizedBox(height: 20),
            _buildCategoryPieChart(context),
            const SizedBox(height: 20),
            _buildMonthlyBarChart(context),
            const SizedBox(height: 20),
            _buildFuelStats(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalExpenses(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Kokonaiskulut',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${expenseProvider.totalExpenses.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryRed,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tässä kuussa: ${expenseProvider.monthExpenses.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryData = expenseProvider.getCategoryExpenses();

    if (categoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Ei kuluja',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final colors = [
      AppTheme.primaryRed,
      AppTheme.darkGray,
      AppTheme.mediumGray,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.brown,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kulut kategoriittain',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categoryData.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final percentage = (data.value / expenseProvider.totalExpenses) * 100;
                    
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: data.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categoryData.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${data.key}: ${data.value.toStringAsFixed(0)} €'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final monthlyData = expenseProvider.getMonthlyExpenses();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kuukausittaiset kulut',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['T', 'H', 'M', 'H', 'T', 'K', 'H', 'E', 'S', 'L', 'M', 'J'];
                          if (value.toInt() >= 1 && value.toInt() <= 12) {
                            return Text(months[value.toInt() - 1]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppTheme.primaryRed,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelStats(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polttoainetilastot',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    title: 'Tankkauskerrat',
                    value: '${expenseProvider.fuelCount}',
                    icon: Icons.local_gas_station,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    title: 'Kokonaiskulutus',
                    value: '${expenseProvider.totalLiters.toStringAsFixed(1)} L',
                    icon: Icons.water_drop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatItem(
              title: 'Keskihinta/litra',
              value: '${expenseProvider.averagePricePerLiter.toStringAsFixed(2)} €/L',
              icon: Icons.euro,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExpenseListPage()),
              );
            },
            icon: const Icon(Icons.list),
            label: const Text('Näytä kululista'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddExpensePage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Lisää kulu'),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
