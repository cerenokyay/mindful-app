import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MindJournalScreen extends StatefulWidget {
  const MindJournalScreen({super.key});

  @override
  State<MindJournalScreen> createState() => _MindJournalScreenState();
}

class _MindJournalScreenState extends State<MindJournalScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  // Hafızadaki eski yazıları yükle
  Future<void> _loadJournal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller.text = prefs.getString('mind_journal') ?? '';
    });
  }

  // Yazılanları hafızaya kaydet
  Future<void> _saveJournal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mind_journal', _controller.text);

    setState(() {
      _isSaved = true;
    });

    // 2 saniye sonra butonu eski haline getir
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3E9), // Gündüz ferahlığı teması
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Ekrana tıklayınca klavyeyi kapat
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.menu_book_outlined, color: Color(0xFF558266), size: 36),
                const SizedBox(height: 24),
                const Text(
                  "Zihin Defteri",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E33),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Zihnini meşgul eden her şeyi buraya bırakabilirsin. Yazmak, düşünceleri somutlaştırır ve yükünü hafifletir.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF3E4E42),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Genişleyebilen Defter Alanı
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E33),
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: "Şu an aklından neler geçiyor...",
                        hintStyle: TextStyle(color: const Color(0xFFB0BEB4).withOpacity(0.8)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(24),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                                "Sayfa kaydedildi",
                                style: TextStyle(color: Color(0xFF558266), fontSize: 16),
                              )
                            ],
                          )
                        : TextButton(
                            onPressed: _saveJournal,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              backgroundColor: const Color(0xFF558266),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Defteri Kapat',
                              style: TextStyle(
                                color: Color(0xFFF5F3E9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}