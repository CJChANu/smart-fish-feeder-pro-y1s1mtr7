import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_fish_feeder_pro/firebase_options.dart';
import 'package:smart_fish_feeder_pro/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final Logger _logger = Logger();
  DatabaseReference? _dbRef;

  bool get isInitialized => _dbRef != null;

  Future<void> init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _dbRef = FirebaseDatabase.instance.ref();
    _logger.i('Firebase initialized');
  }

  DatabaseReference deviceRef([String? deviceId]) =>
      (_dbRef ?? FirebaseDatabase.instance.ref()).child('devices/${deviceId ?? AppConstants.deviceId}');

  // Status stream (live updates) — supports optional deviceId
  Stream<DatabaseEvent> streamStatus([String? deviceId]) => deviceRef(deviceId).child('status').onValue;
  Stream<DatabaseEvent> streamDeviceStatus(String deviceId) => streamStatus(deviceId);

  // Commands — supports optional deviceId
  Future<void> sendFeedCommand([String? deviceId]) async {
    final id = deviceId ?? AppConstants.deviceId;
    await deviceRef(id).child('commands/feedNow').set(true);
    await Future.delayed(const Duration(seconds: 3)); // Wait for ESP32
    await deviceRef(id).child('commands/feedNow').set(false);
  }

  // History stream (last 10) — supports optional deviceId
  Stream<DatabaseEvent> streamHistory([String? deviceId]) =>
      deviceRef(deviceId).child('history').limitToLast(10).onValue;

  // Schedule — supports optional deviceId
  Future<void> setSchedule(List<String> times, [String? deviceId]) async {
    await deviceRef(deviceId).child('schedule/feeding_times').set(times);
  }

  // Alerts — supports optional deviceId
  Stream<DatabaseEvent> streamAlerts([String? deviceId]) =>
      deviceRef(deviceId).child('alerts').onValue;
}
