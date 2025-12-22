import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final Logger _logger = Logger();
  late final DatabaseReference _dbRef;

  Future<void> init() async {
    await Firebase.initializeApp();
    _dbRef = FirebaseDatabase.instance.ref();
    _logger.i('Firebase initialized successfully');
  }

  DatabaseReference deviceRef(String deviceId) => _dbRef.child('devices/$deviceId');
  
  // Stream for real-time device status
  Stream<DatabaseEvent> streamDeviceStatus(String deviceId) {
    return deviceRef(deviceId).child('status').onValue;
  }
  
  // Write command to device
  Future<void> sendFeedCommand(String deviceId) async {
    await deviceRef(deviceId).child('commands/feedNow').set(true);
    await Future.delayed(Duration(seconds: 2));
    await deviceRef(deviceId).child('commands/feedNow').set(false);
  }
}