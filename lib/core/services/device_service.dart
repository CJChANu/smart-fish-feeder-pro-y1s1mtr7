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

  DatabaseReference deviceRef(String deviceId) =>
      (_dbRef ?? FirebaseDatabase.instance.ref()).child('devices/$deviceId');

  // Get user's devices
  Future<List<String>> getUserDevices(String uid) async {
    final snapshot = await (_dbRef ?? FirebaseDatabase.instance.ref()).child('users/$uid/devices').get();
    final raw = snapshot.value;
    if (snapshot.exists && raw != null) {
      if (raw is List) return List<String>.from(raw);
      if (raw is Map) return List<String>.from(raw.keys.map((e) => e.toString()));
    }
    return [];
  }

  // Register new device
  Future<void> registerDevice(String deviceId, String uid, String name) async {
    await deviceRef(deviceId).update({
      'owner': uid,
      'name': name,
      'registeredAt': ServerValue.timestamp,
    });
    // Add to user devices list
    await (_dbRef ?? FirebaseDatabase.instance.ref()).child('users/$uid/devices').runTransaction((dynamic mutableData) {
      if (mutableData == null) return Transaction.abort();
      final list = (mutableData.value as List?) ?? <dynamic>[];
      if (!list.contains(deviceId)) list.add(deviceId);
      mutableData.value = list;
      return Transaction.success(mutableData);
    });
  }

  // Status streams for specific device
  Stream<DatabaseEvent> streamStatus(String deviceId) =>
      deviceRef(deviceId).child('status').onValue;

  Stream<DatabaseEvent> streamHistory(String deviceId) =>
      deviceRef(deviceId).child('history').limitToLast(20).onValue;

  // Commands
  Future<void> sendFeedCommand(String deviceId) async {
    await deviceRef(deviceId).child('commands/feedNow').set(true);
    await Future.delayed(const Duration(seconds: 5));
    await deviceRef(deviceId).child('commands/feedNow').set(false);
  }
}
