import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? deviceId;
  const DashboardScreen({super.key, this.deviceId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppConstants.appName, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen())),
          )
        ],
      ),
      body: StreamBuilder<DatabaseEvent?>(
        stream: FirebaseService().isInitialized ? FirebaseService().streamStatus() : Stream.value(null),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Allow the UI to render even when there's no data yet (e.g., tests / offline)
          final data = (snapshot.hasData && snapshot.data?.snapshot.value != null)
              ? snapshot.data!.snapshot.value as Map<dynamic, dynamic>
              : <dynamic, dynamic>{};
          
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Status Cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    children: [
                      _buildStatusCard('Temperature', '${data['temperature']?.toStringAsFixed(1) ?? 'N/A'}°C', Icons.thermostat),
                      _buildStatusCard('Food Level', data['foodLevel']?.toString() ?? 'N/A', Icons.inventory_2, 
                          data['foodLevel'] == 'low' ? Colors.orange : Colors.green),
                      _buildStatusCard('Water Clarity', '${data['clarity']?.toString() ?? 'N/A'}%', Icons.water_drop),
                      _buildStatusCard('Device', data['online'] == true ? 'Online' : 'Offline', Icons.wifi,
                          data['online'] == true ? Colors.green : Colors.red),
                    ],
                  ),
                ),
                // Feed Now Button
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton.icon(
                    onPressed: FirebaseService().sendFeedCommand,
                    icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                    label: const Text('FEED NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, [Color? color]) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.sp, color: color ?? const Color(0xFF3B82F6)),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
