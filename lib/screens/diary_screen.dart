import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:seohyun_diary/models/diary_entry.dart';
import 'package:seohyun_diary/services/diary_service.dart';

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
    try {
      final diaryData = await DiaryService.loadDiary();
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      
      final entry = diaryData.entries.firstWhere(
        (e) => e.date == dateStr,
        orElse: () => DiaryEntry(date: dateStr, content: ''),
      );
      
      setState(() {
        _controller.text = entry.content;
      });
    } catch (e) {
      print('일기 로드 실패: $e');
    }
  }

  Future<void> _saveDiary() async {
    try {
      if (_controller.text.trim().isEmpty) {
        return; // 빈 내용은 저장하지 않음
      }

      // 현재 모든 일기 데이터 로드
      final diaryData = await DiaryService.loadDiary();
      final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      
      // 현재 시간
      final now = DateTime.now();
      
      // 기존 엔트리 찾기
      final existingEntryIndex = diaryData.entries.indexWhere((e) => e.date == dateStr);
      final entries = List<DiaryEntry>.from(diaryData.entries);

      if (existingEntryIndex >= 0) {
        // 기존 엔트리 업데이트
        final existingEntry = entries[existingEntryIndex];
        final updatedEntry = DiaryEntry(
          id: existingEntry.id,
          date: dateStr,
          content: _controller.text.trim(),
          createdAt: existingEntry.createdAt,
          updatedAt: now,
        );
        entries[existingEntryIndex] = updatedEntry;
      } else {
        // 새 엔트리 추가
        final newEntry = DiaryEntry(
          id: now.millisecondsSinceEpoch.toString(),
          date: dateStr,
          content: _controller.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        entries.add(newEntry);
      }
      
      // 전체 데이터 저장
      final newDiaryData = DiaryData(
        entries: entries,
        version: '1.0.0',
        appName: '서현이일기',
        lastSync: now,
      );
      
      await DiaryService.saveDiary(newDiaryData);
      print('일기 저장 완료: ${_controller.text}'); // 디버그용

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기가 저장되었습니다')),
        );
      }
    } catch (e) {
      print('일기 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 중 오류가 발생했습니다')),
        );
      }
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