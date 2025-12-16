import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/trip_provider.dart';
import '../models/trip.dart';
import '../config/theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearlyChart(context),
            const SizedBox(height: 20),
            _buildTripsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    
    // Calculate monthly data for the year
    Map<int, int> monthlyKm = {};
    for (int month = 1; month <= 12; month++) {
      final monthStart = DateTime(now.year, month, 1);
      final monthEnd = DateTime(now.year, month + 1, 0);
      
      final km = tripProvider.trips
          .where((trip) => 
              trip.date.isAfter(monthStart) && 
              trip.date.isBefore(monthEnd.add(const Duration(days: 1))))
          .fold(0, (sum, trip) => sum + trip.distance);
      
      monthlyKm[month] = km;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vuoden ${now.year} kilometrit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyKm.values.isEmpty 
                      ? 100 
                      : monthlyKm.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = group.x.toInt();
                        final monthNames = [
                          'Tammikuu', 'Helmikuu', 'Maaliskuu', 'Huhtikuu',
                          'Toukokuu', 'Kesäkuu', 'Heinäkuu', 'Elokuu',
                          'Syyskuu', 'Lokakuu', 'Marraskuu', 'Joulukuu'
                        ];
                        return BarTooltipItem(
                          '${monthNames[month - 1]}\n${rod.toY.toInt()} km',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['T', 'H', 'M', 'H', 'T', 'K', 
                                         'H', 'E', 'S', 'L', 'M', 'J'];
                          if (value.toInt() >= 1 && value.toInt() <= 12) {
                            return Text(months[value.toInt() - 1]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyKm.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryRed,
                              AppTheme.primaryRed.withOpacity(0.7),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
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

  Widget _buildTripsList(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trips = tripProvider.trips;

    if (trips.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 64,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ei matkoja',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kaikki matkat',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${trips.length} kpl',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...trips.map((trip) => _TripHistoryItem(trip: trip)),
          ],
        ),
      ),
    );
  }
}

class _TripHistoryItem extends StatelessWidget {
  final Trip trip;

  const _TripHistoryItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isWork = trip.tripType == 'work';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWork ? AppTheme.primaryRed : AppTheme.mediumGray,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWork ? AppTheme.primaryRed : AppTheme.mediumGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isWork ? 'TYÖAJO' : 'YKSITYIS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${trip.distance} km',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.mediumGray),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(trip.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (trip.startAddress != null || trip.endAddress != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.mediumGray),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${trip.startAddress ?? "Lähtö"} → ${trip.endAddress ?? "Kohde"}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          Row(
            children: [
              const Icon(Icons.speed, size: 14, color: AppTheme.mediumGray),
              const SizedBox(width: 4),
              Text(
                '${trip.startOdometer} km → ${trip.endOdometer} km',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (trip.notes != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.note, size: 14, color: AppTheme.mediumGray),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trip.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
