import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Listeyi hafızaya kaydederken çevirmek için gerekli

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Hafızadaki görevleri yükle
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('mindful_tasks');
    if (tasksString != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  // Görevleri hafızaya kaydet
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mindful_tasks', json.encode(_tasks));
  }

  // Yeni görev ekle
  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    
    setState(() {
      _tasks.insert(0, {
        'title': _taskController.text.trim(),
        'isDone': false,
      });
    });
    
    _taskController.clear();
    _saveTasks();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
  }

  // Görev durumunu değiştir (Tamamlandı/Tamamlanmadı)
  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
    _saveTasks();
  }

  // Görevi sil
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 44),
              const Text(
                "Günün Akışı",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E33),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bugün kendini zorlamadan, kendi hızında tamamlamak istediğin küçük adımlar...",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF3E4E42),
                ),
              ),
              const SizedBox(height: 32),
              
              // Yeni Görev Ekleme Alanı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _taskController,
                  onSubmitted: (_) => _addTask(),
                  style: const TextStyle(color: Color(0xFF2C3E33)),
                  decoration: InputDecoration(
                    hintText: "Küçük bir niyet ekle...",
                    hintStyle: TextStyle(color: const Color(0xFFB0BEB4).withOpacity(0.8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF558266)),
                      onPressed: _addTask,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Görevler Listesi
              Expanded(
                child: _tasks.isEmpty
                    ? Center(
                        child: Text(
                          "Şu an liste boş.\nZihnini serbest bırak.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFB0BEB4).withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final isDone = task['isDone'] == true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: isDone ? Colors.transparent : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isDone 
                                    ? Border.all(color: const Color(0xFFB0BEB4).withOpacity(0.5))
                                    : null,
                                boxShadow: isDone
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () => _toggleTask(index),
                                  child: Icon(
                                    isDone ? Icons.check_circle : Icons.circle_outlined,
                                    color: isDone ? const Color(0xFFB0BEB4) : const Color(0xFF558266),
                                  ),
                                ),
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDone ? const Color(0xFFB0BEB4) : const Color(0xFF2C3E33),
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.close, color: const Color(0xFFB0BEB4).withOpacity(0.5), size: 20),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}