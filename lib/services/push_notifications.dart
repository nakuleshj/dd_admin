import 'package:firebase_messaging/firebase_messaging.dart';
class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init(String userID) async {
    if (!_initialized) {
      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
    _firebaseMessaging.subscribeToTopic(userID);
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
      
        },
      );
  }
}