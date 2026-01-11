import 'package:firebase_database/firebase_database.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  DatabaseReference? _dbRef;

  bool get isInitialized => _dbRef != null;

  void init() {
    _dbRef = FirebaseDatabase.instance.ref();
  }

  // The root reference for a specific device, e.g., 'fish_feeder_001'
  DatabaseReference deviceRef(String deviceId) =>
      (_dbRef ?? FirebaseDatabase.instance.ref()).child(deviceId);

  // Data stream from the device, e.g., 'fish_feeder_001/data'
  Stream<DatabaseEvent> streamHistory(String deviceId) =>
      deviceRef(deviceId).child('data').limitToLast(1).onValue;

  Stream<DatabaseEvent> getFullHistory(String deviceId) =>
      deviceRef(deviceId).child('data').limitToLast(50).onValue;

  // Config stream from the device, e.g., 'fish_feeder_001/config'
  Stream<DatabaseEvent> streamConfig(String deviceId) =>
      deviceRef(deviceId).child('config').onValue;

  // Command to trigger manual feeding
  // Sets 'fish_feeder_001/config/manual_feed' to true
  Future<void> sendFeedCommand(String deviceId) async {
    await deviceRef(deviceId).child('config/manual_feed').set(true);
  }

  // Command to set the feeding interval
  // Sets 'fish_feeder_001/config/feed'
  Future<void> setFeedInterval(String deviceId, int hours) async {
    await deviceRef(deviceId).child('config/feed').set(hours);
  }
}
