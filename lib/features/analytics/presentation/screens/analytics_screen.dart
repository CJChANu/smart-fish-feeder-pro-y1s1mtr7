
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_fish_feeder_pro/core/services/device_service.dart';
import 'package:intl/intl.dart';

// Provider for the full history
final fullHistoryProvider = StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, deviceId) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.getFullHistory(deviceId).map((event) {
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final history = data.entries.map((e) {
        final entryData = Map<String, dynamic>.from(e.value as Map);
        // The key is the timestamp, e.g., NO_RTC_1715846400000 or a full ISO string
        final key = e.key;
        DateTime timestamp;
        try {
          timestamp = DateTime.parse(key.split('.')[0]); // From ISO string
        } catch (e) {
          // Fallback for NO_RTC_... keys
          final ms = int.tryParse(key.split('_').last) ?? 0;
          timestamp = DateTime.fromMillisecondsSinceEpoch(ms);
        }

        return {
          'timestamp': timestamp,
          'temp': entryData['temp'] ?? 0,
          'ph': entryData['ph'] ?? 0,
          'turbidity': entryData['turbidity'] ?? 0,
        };
      }).toList();

      history.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      return history;
    }
    return [];
  });
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(fullHistoryProvider('fish_feeder_001'));

    return Scaffold(
      body: history.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No data available.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Data Over Time', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                _buildChart(context, 'Temperature (°C)', data, 'temp', Colors.orange),
                const SizedBox(height: 24),
                _buildChart(context, 'pH Level', data, 'ph', Colors.blue),
                const SizedBox(height: 24),
                _buildChart(context, 'Turbidity (%)', data, 'turbidity', Colors.cyan),
                const Divider(height: 48),
                Text('Last Feed Times', style: Theme.of(context).textTheme.headlineSmall),
                _buildFeedLog(data), // We are faking this for now
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildChart(BuildContext context, String title, List<Map<String, dynamic>> data, String key, Color color) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value[key] as num).toDouble());
    }).toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ]
    );
  }

  Widget _buildFeedLog(List<Map<String, dynamic>> data) {
    // This is just a placeholder, as the feed time is not in the history data
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.fastfood),
          title: Text('Manual Feed'),
          subtitle: Text(DateFormat.yMMMd().add_jms().format(DateTime.now().subtract(Duration(hours: index * 5, minutes: 15)))),
        );
      },
    );
  }
}
