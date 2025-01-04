import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DiaryScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryScreen({super.key, required this.selectedDate});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    _prefs = await SharedPreferences.getInstance();
    final key = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    setState(() {
      _controller.text = _prefs.getString(key) ?? '';
    });
  }

  Future<void> _saveDiary() async {
    final key = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    await _prefs.setString(key, _controller.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기가 저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          top: true,
          minimum: const EdgeInsets.only(top: 20),
          child: AppBar(
            toolbarHeight: 120,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: '오늘의 일기를 작성해주세요',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                        locale: Locale('ko', 'KR'),
                      ),
                      enableInteractiveSelection: true,
                      textAlign: TextAlign.start,
                      autofocus: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _saveDiary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('저장'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('지우기'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('닫기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              border: const Border(
                top: BorderSide(
                  color: Colors.blue,
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: const [
                  Text(
                    '서현아! 할아버지가 만들어준 일기장이란다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2024 서현이일기. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 