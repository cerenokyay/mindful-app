import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart'; // Hafıza için ekledik
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart'; // Giriş ekranını içe aktardık

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // UYGULAMA AÇILMADAN ÖNCE: Kullanıcı giriş yapmış mı kontrol et
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  // Başlangıç ekranını oturum durumuna göre seçip uygulamayı başlatıyoruz
  runApp(MindfulApp(isLoggedIn: isLoggedIn));
}

class MindfulApp extends StatelessWidget {
  final bool isLoggedIn;
  
  // Kurucu metoda oturum bilgisini istiyoruz
  const MindfulApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Eğer giriş yapıldıysa MainScreen'e, yapılmadıysa AuthScreen'e git
      home: isLoggedIn ? const MainScreen() : const AuthScreen(),
    );
  }
}