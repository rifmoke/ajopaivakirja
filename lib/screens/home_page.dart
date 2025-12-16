import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/trip_provider.dart';
import '../config/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajopäiväkirja'),
        actions: [
          IconContainer(
            icon: Icons.today,
            color: AppTheme.primaryRed,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TripProvider>().loadTrips();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCards(context),
              const SizedBox(height: 20),
              _buildWorkPrivateProgress(context),
              const SizedBox(height: 20),
              _buildWeeklyChart(context),
              const SizedBox(height: 20),
              _buildRecentTrips(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Kokonais-\nkilometrit',
            value: '${tripProvider.totalKilometers} km',
            icon: Icons.route,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Kuukauden\nkilometrit',
            value: '${tripProvider.monthKilometers} km',
            icon: Icons.calendar_month,
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkPrivateProgress(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final workKm = tripProvider.workKilometers;
    final privateKm = tripProvider.privateKilometers;
    final total = workKm + privateKm;
    
    final workPercent = total > 0 ? (workKm / total) : 0.0;
    final privatePercent = total > 0 ? (privateKm / total) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Työajo vs. Yksityisajo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: (workPercent * 100).toInt(),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(12),
                        right: privatePercent == 0 
                            ? const Radius.circular(12) 
                            : Radius.zero,
                      ),
                    ),
                  ),
                ),
                if (privatePercent > 0)
                  Expanded(
                    flex: (privatePercent * 100).toInt(),
                    child: Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.mediumGray,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Työajo: $workKm km (${(workPercent * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.mediumGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Yksityis: $privateKm km (${(privatePercent * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final weeklyData = tripProvider.getWeeklyKilometers();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viikon kilometrit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Ma', 'Ti', 'Ke', 'To', 'Pe', 'La', 'Su'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
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
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData.entries.map((e) {
                        final index = weeklyData.keys.toList().indexOf(e.key);
                        return FlSpot(index.toDouble(), e.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryRed,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryRed.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final recentTrips = tripProvider.recentTrips;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viimeisimmät matkat',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            if (recentTrips.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Ei vielä matkoja'),
                ),
              )
            else
              ...recentTrips.map((trip) => _TripListItem(trip: trip)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Theme.of(context).primaryColor : color;
    final valueColor = isDark ? Theme.of(context).colorScheme.onSurface : color;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripListItem extends StatelessWidget {
  final dynamic trip;

  const _TripListItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: trip.tripType == 'work' ? AppTheme.primaryRed : AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.startAddress ?? "Lähtö"} → ${trip.endAddress ?? "Kohde"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateFormat.format(trip.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${trip.distance} km',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon, color: color),
    );
  }
}
