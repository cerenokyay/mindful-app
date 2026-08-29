import 'package:flutter/material.dart';
import 'dart:math';

void main() {
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
            child: Center(
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
          ),
        );
      },
    );
  }
}