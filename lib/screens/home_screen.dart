import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seohyun_diary/screens/diary_screen.dart';
import 'package:seohyun_diary/screens/settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late SharedPreferences _prefs;
  Set<String> _diaryDates = {};

  @override
  void initState() {
    super.initState();
    _loadDiaryDates();
    
    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // 애니메이션 설정
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryDates() async {
    _prefs = await SharedPreferences.getInstance();
    final keys = _prefs.getKeys();
    setState(() {
      _diaryDates = keys.where((key) => key.contains('-')).toSet();
    });
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
          Expanded(
            child: TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
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
                  color: Colors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: Color.fromRGBO(233, 30, 99, 0.1),
                  shape: BoxShape.circle,
                ),
                outsideTextStyle: TextStyle(color: Colors.grey),
                cellMargin: EdgeInsets.all(6),
              ),
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryScreen(selectedDate: selectedDay),
                  ),
                );
                
                // 일기 작성 후 돌아왔을 때 날짜 표시 업데이트
                _loadDiaryDates();
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dateStr = DateFormat('yyyy-MM-dd').format(date);
                  if (_diaryDates.contains(dateStr)) {
                    return Positioned(
                      bottom: 1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                        ),
                        width: 6.0,
                        height: 6.0,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 20), // 달력과 아이콘 사이 간격
          // 원형 아이콘 위젯
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
                radius: 75, // 이미지 크기를 결정하는 radius 값 (40 = 80x80 픽셀)
                backgroundImage: const AssetImage('assets/images/seohyun.jpg'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 푸터 위젯
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
                    '© 2025 서현이의 일기장. All rights reserved.',
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
} 