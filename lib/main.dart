import 'package:flutter/material.dart';
import 'package:seohyun_diary/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:seohyun_diary/screens/password_screen.dart';
import 'package:seohyun_diary/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  
  // 백그라운드 서비스 초기화 및 스케줄링
  await BackgroundService.initialize();
  await BackgroundService.scheduleWeeklyBackup();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '서현이일기',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'NanumGothic',
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          // 입력 필드의 기본 스타일 설정
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16.0),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko', 'KR'),
      home: const PasswordScreen(),
    );
  }
}
