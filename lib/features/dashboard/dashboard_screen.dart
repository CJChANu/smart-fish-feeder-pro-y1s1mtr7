import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = AppConstants.deviceId;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Fish Feeder Pro', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseService().streamDeviceStatus(deviceId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Connection Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
          
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
                      _buildStatusCard('Temperature', '${data['temperature']?.toString() ?? 'N/A'}°C', Icons.thermostat),
                      _buildStatusCard('Food Level', data['foodLevel'] == 'low' ? 'LOW' : 'OK', Icons.inventory_2),
                      _buildStatusCard('Water Clarity', '${data['clarity']?.toString() ?? 'N/A'}%', Icons.water_drop),
                      _buildStatusCard('Last Feed', data['lastFeeding']?.toString() ?? 'Never', Icons.access_time),
                    ],
                  ),
                ),
                // Feed Now Button
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: () => FirebaseService().sendFeedCommand(deviceId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('FEED NOW', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.sp, color: Color(0xFF3B82F6)),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
