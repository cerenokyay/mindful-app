import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Gezgin";
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Gezgin";
      _userEmail = prefs.getString('user_email') ?? "";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false); // Çıkış yapıldı olarak işaretle
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false, // Tüm sayfa geçmişini siler (Geri tuşu ile tekrar girmesin diye)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF558266).withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: Color(0xFF558266)),
              ),
              const SizedBox(height: 24),
              Text(
                _userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E33)),
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail,
                style: const TextStyle(fontSize: 16, color: Color(0xFF3E4E42)),
              ),
              const SizedBox(height: 40),
              
              // Ayarlar Listesi
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined, color: Color(0xFF558266)),
                      title: const Text("Hesap Bilgileri", style: TextStyle(color: Color(0xFF2C3E33))),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFB0BEB4)),
                      onTap: () {}, // Gelecekte eklenecek
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: Color(0xFF558266)),
                      title: const Text("Gizlilik ve Güvenlik", style: TextStyle(color: Color(0xFF2C3E33))),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFB0BEB4)),
                      onTap: () {}, // Gelecekte eklenecek
                    ),
                  ],
                ),
              ),
              
              // Çıkış Yap Butonu
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}