import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:seohyun_diary/services/diary_service.dart';

class EmailService {
  static const String _recipientEmail = 'rangrangorg@gmail.com';
  
  static final smtpServer = gmail(
    'your_email@gmail.com',     // 발신 이메일 주소
    'your_app_password',        // Gmail 앱 비밀번호
  );

  static Future<void> sendDiaryBackup() async {
    try {
      final diaryFile = await DiaryService.getDiaryFile();
      final backupFile = await DiaryService.getBackupFile();

      // 메시지 생성
      final message = Message()
        ..from = Address('your_email@gmail.com', '서현이일기')
        ..recipients.add(_recipientEmail)
        ..subject = '서현이일기 자동 백업 (${DateTime.now().toString().split(' ')[0]})'
        ..text = '서현이의 소중한 일기가 첨부되어 있습니다.'
        ..attachments = [
          FileAttachment(diaryFile),
          FileAttachment(backupFile),
        ];

      // 이메일 전송
      await send(message, smtpServer);
    } catch (e) {
      print('이메일 전송 실패: $e');
      // 오류 처리
    }
  }
} 