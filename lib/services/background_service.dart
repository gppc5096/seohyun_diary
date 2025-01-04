import 'package:workmanager/workmanager.dart';
import 'package:seohyun_diary/services/email_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'sendDiaryBackup':
          await EmailService.sendDiaryBackup();
          break;
      }
      return true;
    } catch (e) {
      print('Background task failed: $e');
      return false;
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleWeeklyBackup() async {
    await Workmanager().registerPeriodicTask(
      'weeklyBackup',
      'sendDiaryBackup',
      frequency: const Duration(days: 7),
      initialDelay: _getInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final saturday = _nextSaturday(now);
    final targetTime = DateTime(
      saturday.year,
      saturday.month,
      saturday.day,
      10, // 오전 10시
      0,
    );
    return targetTime.difference(now);
  }

  static DateTime _nextSaturday(DateTime from) {
    int daysUntilSaturday = DateTime.saturday - from.weekday;
    if (daysUntilSaturday <= 0) {
      daysUntilSaturday += 7;
    }
    return from.add(Duration(days: daysUntilSaturday));
  }
} 