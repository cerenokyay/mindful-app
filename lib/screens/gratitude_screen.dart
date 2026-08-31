import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadGratitudes();
  }

  Future<void> _loadGratitudes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller1.text = prefs.getString('gratitude_1') ?? '';
      _controller2.text = prefs.getString('gratitude_2') ?? '';
      _controller3.text = prefs.getString('gratitude_3') ?? '';
    });
  }

  Future<void> _saveGratitudes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gratitude_1', _controller1.text);
    await prefs.setString('gratitude_2', _controller2.text);
    await prefs.setString('gratitude_3', _controller3.text);
    
    setState(() {
      _isSaved = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Widget _buildGratitudeField(int index, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFF5F3E9), fontSize: 16),
        cursorColor: const Color(0xFF558266),
        maxLines: null,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "$index. Bugün minnettar olduğum şey...",
          hintStyle: TextStyle(color: const Color(0xFFB0BEB4).withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0xFF2C3E33),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2923),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.nightlight_round, color: Color(0xFFD8C3A5), size: 36),
                const SizedBox(height: 24),
                const Text(
                  "Gece Şükranı",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5F3E9),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Günün karmaşası bitti. Şimdi sadece sana iyi hissettiren, gülümseten ya da huzur veren üç küçük anı hatırla.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFFB0BEB4),
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildGratitudeField(1, _controller1),
                _buildGratitudeField(2, _controller2),
                _buildGratitudeField(3, _controller3),
                
                const SizedBox(height: 20),
                
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isSaved
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF558266)),
                              SizedBox(width: 8),
                              Text(
                                "Huzurla kaydedildi",
                                style: TextStyle(color: Color(0xFF558266), fontSize: 16),
                              )
                            ],
                          )
                        : TextButton(
                            onPressed: _saveGratitudes,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              backgroundColor: const Color(0xFF2C3E33),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Günü Tamamla',
                              style: TextStyle(
                                color: Color(0xFFF5F3E9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}