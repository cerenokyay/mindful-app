import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'todo_screen.dart';
import 'gratitude_screen.dart';
import 'mind_journal_screen.dart';
import 'profile_screen.dart'; // Profil sayfasını içe aktardık

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BreathingScreen(),
    const TodoScreen(),
    const GratitudeScreen(),
    const MindJournalScreen(),
    const ProfileScreen(), // 5. sayfa olarak listeye eklendi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF5F3E9),
        selectedItemColor: const Color(0xFF558266),
        unselectedItemColor: const Color(0xFFB0BEB4),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11), // 5 sekme olduğu için fontu 1 tık küçülttük
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.spa_outlined), activeIcon: Icon(Icons.spa), label: 'Nefes'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), activeIcon: Icon(Icons.check_circle), label: 'Akış'),
          BottomNavigationBarItem(icon: Icon(Icons.nightlight_outlined), activeIcon: Icon(Icons.nightlight), label: '3 Şükür'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Defter'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'), // 5. sekme butonu
        ],
      ),
    );
  }
}