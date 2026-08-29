import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Bildirim motorunu global olarak tanımlıyoruz
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // Arka plan işlemleri için Flutter'ı hazırlıyoruz
  WidgetsFlutterBinding.ensureInitialized();
  
  // Saat dilimlerini yüklüyoruz (Zamanlanmış bildirimler için şart)
  tz.initializeTimeZones();

  // Android bildirim ayarları (Uygulamanın varsayılan ikonunu kullanır)
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MindfulApp());
}

class MindfulApp extends StatelessWidget {
  const MindfulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BreathingScreen(),
    );
  }
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _bgColorAnimation;
  
  String _currentWhisper = "Şu an buradasın ve her şey yolunda.";
  String _notificationPreference = "off"; 

  final List<String> _whispers = [
    "Beynimiz her an yeniden şekilleniyor. Şu anki dinginliğin zihninde yeni bir patika açıyor.",
    "Kuantum seviyesinde her şey birbiriyle bağlantılı. Tıpkı zihnin ve bedeninin şu anki uyumu gibi.",
    "Kendi sınırlarını korumak ve durup dinlenmeyi seçmek en temel hakkındır.",
    "Sadece nefesine odaklanarak merkezine dön. Dışarıdaki hayat bu dengeyi bekleyebilir.",
    "Şu an hiçbir yere yetişmen gerekmiyor.",
  ];

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission(); // Bildirim izni iste
    _loadPreference(); 
    
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _sizeAnimation = Tween<double>(begin: 120.0, end: 260.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _bgColorAnimation = ColorTween(
      begin: const Color(0xFFB0BEB4), 
      end: const Color(0xFFF5F3E9),   
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  // Android 13 ve sonrası için bildirim izni isteme
  void _requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationPreference = prefs.getString('notification_pref') ?? 'off';
    });
  }

  // Tercihi kaydedip bildirimleri planlayan fonksiyon
  Future<void> _savePreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_pref', value);
    setState(() {
      _notificationPreference = value;
    });
    
    _updateNotifications(value);
  }

  // BİLDİRİM MOTORU: Tercihe göre bildirimleri ayarlar
  Future<void> _updateNotifications(String pref) async {
    // Önce eski bildirimleri temizle
    await flutterLocalNotificationsPlugin.cancelAll();

    if (pref == 'off') return;

    final random = Random();
    
    if (pref == 'daily') {
      // Sabah 09:00, Öğle 14:00, Akşam 20:00
      _scheduleDailyNotification(0, 9, 0, _whispers[random.nextInt(_whispers.length)]);
      _scheduleDailyNotification(1, 14, 0, _whispers[random.nextInt(_whispers.length)]);
      _scheduleDailyNotification(2, 20, 0, _whispers[random.nextInt(_whispers.length)]);
    } else if (pref == 'random') {
      // 10:00 ile 20:00 arası 3 rastgele saat
      for (int i = 0; i < 3; i++) {
        int randomHour = 10 + random.nextInt(11);
        int randomMinute = random.nextInt(60);
        _scheduleDailyNotification(i, randomHour, randomMinute, _whispers[random.nextInt(_whispers.length)]);
      }
    }
  }

  // Belirli bir saate her gün tekrar eden bildirim kurma fonksiyonu
  Future<void> _scheduleDailyNotification(int id, int hour, int minute, String whisper) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Eğer saat geçmişse yarına kur
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mindful_whispers_channel',
      'Mindful Fısıltılar',
      channelDescription: 'Günlük rahatlama hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Derin bir nefes...',
      whisper,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrar etmesi için
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getNewWhisper() {
    setState(() {
      final random = Random();
      _currentWhisper = _whispers[random.nextInt(_whispers.length)];
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F3E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Fısıltı Tercihleri",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E33),
                    ),
                  ),
                  const SizedBox(height: 24),
                  RadioListTile<String>(
                    title: const Text("Sabah, Öğle, Akşam", style: TextStyle(color: Color(0xFF3E4E42))),
                    value: "daily",
                    groupValue: _notificationPreference,
                    activeColor: const Color(0xFF558266),
                    onChanged: (value) {
                      setModalState(() => _notificationPreference = value!);
                      _savePreference(value!);
                      Navigator.pop(context); // Seçim yapınca menüyü kapat
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Rastgele Zamanlarda", style: TextStyle(color: Color(0xFF3E4E42))),
                    value: "random",
                    groupValue: _notificationPreference,
                    activeColor: const Color(0xFF558266),
                    onChanged: (value) {
                      setModalState(() => _notificationPreference = value!);
                      _savePreference(value!);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Şimdilik Kapat", style: TextStyle(color: Color(0xFF3E4E42))),
                    value: "off",
                    groupValue: _notificationPreference,
                    activeColor: const Color(0xFF558266),
                    onChanged: (value) {
                      setModalState(() => _notificationPreference = value!);
                      _savePreference(value!);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        String instruction = _controller.status == AnimationStatus.forward 
            ? 'Nefes Al...' 
            : 'Nefes Ver...';

        return Scaffold(
          backgroundColor: _bgColorAnimation.value,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.spa_outlined, color: Color(0xFF558266), size: 32),
                    onPressed: _showSettingsModal,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        instruction,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2C3E33), 
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        width: _sizeAnimation.value,
                        height: _sizeAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF558266).withOpacity(_opacityAnimation.value),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF558266).withOpacity(_opacityAnimation.value * 0.4),
                              blurRadius: _sizeAnimation.value * 0.25,
                              spreadRadius: _sizeAnimation.value * 0.05,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _currentWhisper,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3E4E42),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextButton(
                        onPressed: _getNewWhisper,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFF558266), width: 1.5),
                          ),
                        ),
                        child: const Text(
                          'Bana iyi bir şey söyle',
                          style: TextStyle(
                            color: Color(0xFF2C3E33),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}