
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_fish_feeder_pro/core/services/device_service.dart';
import 'package:smart_fish_feeder_pro/features/analytics/presentation/screens/analytics_screen.dart';

// Provider for the DeviceService
final deviceServiceProvider = Provider((ref) => DeviceService());

// Provider for the device data stream
final deviceDataStreamProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, deviceId) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.streamHistory(deviceId).map((event) {
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      // Assuming the latest data is the first entry
      final latestData =
          Map<String, dynamic>.from(data.values.first as Map);
      return {
        'temp': latestData['temp'] ?? 0,
        'ph': latestData['ph'] ?? 0,
        'turbidity': latestData['turbidity'] ?? 0,
      };
    }
    return {'temp': 0, 'ph': 0, 'turbidity': 0};
  });
});

// Provider for the device config stream
final deviceConfigStreamProvider =
    StreamProvider.autoDispose.family<Map<String, dynamic>, String>((ref, deviceId) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.streamConfig(deviceId).map((event) {
    if (event.snapshot.value != null) {
      final config = Map<String, dynamic>.from(event.snapshot.value as Map);
      return {
        'feed': config['feed'] ?? 0,
      };
    }
    return {'feed': 0};
  });
});

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    AnalyticsScreen(),
    Text('Setup Screen'), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.waves),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard'),
            Text(
              'SYSTEM ONLINE',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh action
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'ANALYTICS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETUP',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Replace with your actual device ID
    final deviceId = 'fish_feeder_001';
    final data = ref.watch(deviceDataStreamProvider(deviceId));
    final config = ref.watch(deviceConfigStreamProvider(deviceId));

    return data.when(
      data: (deviceData) {
        return config.when(
          data: (deviceConfig) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'WATER TEMP',
                          '${deviceData['temp']} °C',
                          Icons.thermostat,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'PH LEVEL',
                          '${deviceData['ph']} Avg',
                          Icons.opacity,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTurbidityCard(context, (deviceData['turbidity'] as num).toDouble()),
                  const SizedBox(height: 16),
                  _buildControlCard(context, ref, deviceId, deviceConfig['feed'] ?? 0),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value,
      IconData icon, Color iconColor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildTurbidityCard(BuildContext context, double value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.waves, color: Colors.cyan),
                SizedBox(width: 8),
                Text('TURBIDITY INDEX'),
                Spacer(),
                Text('20%'), // This is hardcoded based on the image
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value / 100, // Assuming turbidity is 0-100
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            const Text(
              'Higher percentage indicates cloudier water.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(BuildContext context, WidgetRef ref, String deviceId, int feedInterval) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manual Feed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(deviceServiceProvider).sendFeedCommand(deviceId);
                },
                child: const Text('FEED NOW'),
              ),
            ),
            const Divider(height: 32),
            Text('Feeding Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Text('Presets:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () => ref.read(deviceServiceProvider).setFeedInterval(deviceId, 8), child: const Text('8 hours')),
                ElevatedButton(onPressed: () => ref.read(deviceServiceProvider).setFeedInterval(deviceId, 12), child: const Text('12 hours')),
                ElevatedButton(onPressed: () => ref.read(deviceServiceProvider).setFeedInterval(deviceId, 24), child: const Text('24 hours')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Custom: Every $feedInterval hours'),
            Slider(
              value: feedInterval.toDouble(),
              min: 0,
              max: 48, // Max 48 hours
              divisions: 48,
              label: feedInterval.toString(),
              onChanged: (double value) {
                // Local state update can be added here for more responsive UI
              },
              onChangeEnd: (double value) { // Update Firebase on change end
                 ref.read(deviceServiceProvider).setFeedInterval(deviceId, value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}
