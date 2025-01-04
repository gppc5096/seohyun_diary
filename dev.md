
# Flutter 데이터 관리 및 이메일 자동 전송 기술 문서

## 1. 앱 내 '설정' 페이지에 '파일내보내기' 및 '파일가져오기' 기능 구현

### 1.1 파일내보내기 (Export)
- 사용자가 앱 데이터를 로컬 디바이스에 저장할 수 있는 기능입니다.
- 저장 데이터는 JSON 형식으로 생성됩니다.
- 데이터 파일 저장 경로: 앱 전용 디렉토리 (Path: `getApplicationDocumentsDirectory`).
- 파일명 예시:
  - `diary.json` (일기 기록 데이터)
  - `backup.json` (앱 복원용 데이터)

### 1.2 파일가져오기 (Import)
- 사용자가 기존 저장된 JSON 데이터를 앱으로 불러올 수 있는 기능입니다.
- 파일 선택 UI를 제공하여 사용자가 디바이스에서 JSON 파일을 선택할 수 있습니다.
- JSON 파일을 읽고, 앱 데이터 구조로 파싱하여 복원.

### 구현 예시
#### 파일내보내기 코드:
```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> exportFile(String fileName, String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);
}
```

#### 파일가져오기 코드:
```dart
import 'dart:io';
import 'dart:convert';

Future<String> importFile(String filePath) async {
  final file = File(filePath);
  final content = await file.readAsString();
  final data = jsonDecode(content); // JSON 파싱
  return data;
}
```

---

## 2. 저장 데이터 형식: JSON
- **일기 기록 데이터 (diary.json):**
```json
{
  "entries": [
    {
      "date": "2025-01-01",
      "content": "새해 첫 일기!"
    },
    {
      "date": "2025-01-02",
      "content": "Flutter 배우기!"
    }
  ]
}
```

- **앱 복원용 데이터 (backup.json):**
```json
{
  "settings": {
    "theme": "dark",
    "fontSize": 14
  },
  "userData": {
    "lastLogin": "2025-01-03",
    "preferences": {
      "notifications": true
    }
  }
}
```

---

## 3. 데이터를 지정한 이메일로 자동 전송 기능

### 3.1 기능 설명
- 이메일 주소: `rangrangorg@gmail.com` (하드코딩된 기본값)
- 전송 주기: 매 주 토요일 오전 10:00
- 첨부파일:
  1. `diary.json`: 일기 기록 데이터
  2. `backup.json`: 앱 복원용 데이터

### 3.2 구현 방법
#### 스케줄링: `workmanager` 패키지 사용
- 백그라운드에서 주기적인 작업 실행.
- 매주 토요일 오전 10:00에 작업을 예약.

#### 이메일 전송: `mailer` 패키지 사용
- SMTP 서버 (예: Gmail)를 이용하여 이메일 전송.

#### 코드 예시
```dart
import 'package:workmanager/workmanager.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final directory = await getApplicationDocumentsDirectory();
    final diaryFile = File('${directory.path}/diary.json');
    final backupFile = File('${directory.path}/backup.json');

    final smtpServer = gmail('your_email@gmail.com', 'your_email_password');
    final message = Message()
      ..from = Address('your_email@gmail.com', 'Diary App')
      ..recipients.add('rangrangorg@gmail.com')
      ..subject = 'Weekly Diary and Backup Data'
      ..text = '첨부된 파일에 데이터가 포함되어 있습니다.'
      ..attachments = [
        FileAttachment(diaryFile),
        FileAttachment(backupFile),
      ];

    try {
      await send(message, smtpServer);
      print("이메일 전송 성공!");
    } catch (e) {
      print("이메일 전송 실패: $e");
    }
    return Future.value(true);
  });
}

void scheduleEmailTask() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "weeklyEmailTask",
    "sendEmail",
    frequency: Duration(days: 7),
    inputData: {"time": "Saturday 10:00 AM"},
  );
}
```

---

## 4. 보안 및 기타 고려사항
1. **이메일 보안:** 앱 비밀번호 또는 OAuth 인증을 사용하는 것이 좋습니다.
2. **JSON 파일 크기:** 파일 크기가 커질 경우, 데이터를 압축하거나 파일 분할 필요.
3. **오류 처리:** 이메일 전송 실패 시 재시도 로직 구현 권장.

---

## 5. 종합 테스트 플랜
1. 앱에서 데이터 내보내기/가져오기 테스트.
2. JSON 데이터 파일 생성 및 이메일 첨부 확인.
3. 스케줄링 기능이 올바르게 작동하는지 검증.
4. 이메일 전송 성공 및 실패 시 예외 처리 확인.
5. 다양한 JSON 데이터 크기 및 구조에 대한 성능 테스트.

---

## 참고
- [path_provider 패키지](https://pub.dev/packages/path_provider)
- [mailer 패키지](https://pub.dev/packages/mailer)
- [workmanager 패키지](https://pub.dev/packages/workmanager)
