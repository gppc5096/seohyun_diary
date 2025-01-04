import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:seohyun_diary/services/diary_service.dart';

class EmailService {
  static const String _recipientEmail = 'rangrangorg@gmail.com';
  
  static final smtpServer = gmail(
    'rangrangorg@gmail.com', // 보내는 사람 이메일
    'uhti ytus ntzg yyqo'  // Gmail 앱 비밀번호
  );

  static Future<void> sendDiaryBackup() async {
    try {
      // 백업 파일 생성
      await DiaryService.createBackup();
      
      final diaryFile = await DiaryService.getDiaryFile();
      final backupFile = await DiaryService.getBackupFile();

      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final message = Message()
        ..from = Address(_recipientEmail, '서현이일기')
        ..recipients.add(_recipientEmail)
        ..subject = '서현이일기 자동 백업 ($dateStr)'
        ..text = '''
서현이의 소중한 일기가 첨부되어 있습니다.

1. diary.json: 일기 기록 데이터
2. backup.json: 앱 복원용 데이터 (설정 및 사용자 데이터 포함)

전송 시간: ${now.toString()}
'''
        ..attachments = [
          FileAttachment(diaryFile),
          FileAttachment(backupFile),
        ];

      final sendReport = await send(message, smtpServer);
      print('이메일 전송 성공: ${sendReport.toString()}');
    } catch (e) {
      print('이메일 전송 실패: $e');
      rethrow;
    }
  }

  static Future<void> sendMessage(String messageText) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final message = Message()
        ..from = Address(_recipientEmail, '서현이일기')
        ..recipients.add(_recipientEmail)
        ..subject = '서현이가 보낸 메시지 ($dateStr)'
        ..text = messageText;

      final sendReport = await send(message, smtpServer);
      print('메시지 전송 성공: ${sendReport.toString()}');
    } catch (e) {
      print('메시지 전송 실패: $e');
      rethrow;
    }
  }
} 