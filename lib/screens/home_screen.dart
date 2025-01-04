import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:seohyun_diary/screens/diary_screen.dart';
import 'package:seohyun_diary/screens/settings_screen.dart';
import 'package:seohyun_diary/services/diary_service.dart';
import 'package:seohyun_diary/screens/message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animation;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _diaryDates = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      debugLabel: null,
    )..repeat();
    _loadDiaryDates();
  }

  Future<void> _loadDiaryDates() async {
    try {
      final diaryData = await DiaryService.loadDiary();
      setState(() {
        _diaryDates = diaryData.entries
            .map((e) => DateFormat('yyyy-MM-dd').parse(e.date))
            .toSet();
      });
    } catch (e) {
      print('일기 날짜 로드 실패: $e');
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _animation,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '서현이일기',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScaleTransition(
                    scale: _animation,
                    child: const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 20),
                child: IconButton(
                  icon: const Icon(
                    Icons.email,
                    color: Colors.pink,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessageScreen()),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 20),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.green,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _openDiaryScreen(selectedDay);
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            daysOfWeekHeight: 40,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              weekendStyle: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            calendarStyle: const CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(fontSize: 16),
              weekendTextStyle: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromRGBO(76, 175, 80, 0.1),
                shape: BoxShape.circle,
              ),
              outsideTextStyle: TextStyle(color: Colors.grey),
              cellMargin: EdgeInsets.all(6),
            ),
            eventLoader: (day) {
              return _diaryDates.contains(DateTime(
                day.year,
                day.month,
                day.day,
              )) ? [true] : [];
            },
            locale: 'ko_KR',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Hero(
              tag: 'seohyun_icon',
              child: CircleAvatar(
                backgroundColor: Colors.pink.withOpacity(0.1),
                radius: 75,
                backgroundImage: const AssetImage('assets/images/seohyun.jpg'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              border: const Border(
                top: BorderSide(
                  color: Colors.pink,
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: const [
                  Text(
                    '서현아! 매일 잠자기 전에 일기를 쓰면 좋을거야!.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 서현이일기. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  void _openDiaryScreen(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryScreen(selectedDate: selectedDate),
      ),
    ).then((_) => _loadDiaryDates());  // 일기 화면에서 돌아올 때 날짜 다시 로드
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
} 