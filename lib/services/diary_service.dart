import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:seohyun_diary/models/diary_entry.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';

class DiaryService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _diaryFile async {
    final path = await _localPath;
    return File('$path/diary.json');
  }

  static Future<File> get _backupFile async {
    final path = await _localPath;
    return File('$path/backup.json');
  }

  // public 메서드 추가
  static Future<File> getDiaryFile() async {
    return await _diaryFile;
  }

  static Future<File> getBackupFile() async {
    return await _backupFile;
  }

  // 일기 데이터 저장
  static Future<void> saveDiary(DiaryData data) async {
    final file = await _diaryFile;
    await file.writeAsString(data.toJsonString());
  }

  // 일기 데이터 불러오기
  static Future<DiaryData> loadDiary() async {
    try {
      final file = await _diaryFile;
      if (!await file.exists()) {
        // 파일이 없으면 빈 데이터 생성
        final emptyData = DiaryData(entries: []);
        await saveDiary(emptyData);  // 빈 파일 생성
        return emptyData;
      }
      
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return DiaryData(entries: []);
      }

      final data = DiaryData.fromJson(jsonDecode(contents));
      print('로드된 일기 수: ${data.entries.length}');  // 디버그용
      return data;
    } catch (e) {
      print('일기 로드 실패: $e');  // 디버그용
      return DiaryData(entries: []);
    }
  }

  // 백업 파일 생성
  static Future<void> createBackup() async {
    try {
      final diaryData = await loadDiary();
      print('백업할 일기 수: ${diaryData.entries.length}');  // 디버그용
      
      final backupFile = await _backupFile;
      await backupFile.writeAsString(diaryData.toJsonString());
    } catch (e) {
      print('백업 생성 실패: $e');  // 디버그용
      rethrow;
    }
  }

  // 백업 파일에서 복원
  static Future<bool> restoreFromBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final contents = await file.readAsString();
        
        // JSON 파싱 및 데이터 복원
        final diaryData = DiaryData.fromJson(jsonDecode(contents));
        await saveDiary(diaryData);  // 앱 내부 저장소에 저장
        
        print('복원된 일기 수: ${diaryData.entries.length}');
        return true;
      }
      return false;
    } catch (e) {
      print('복원 실패: $e');
      return false;
    }
  }

  // 사용자가 선택한 위치에 백업 파일 저장
  static Future<bool> exportToSelectedLocation(BuildContext context) async {
    try {
      // 1. 권한 체크 및 요청
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      bool hasPermission = false;

      if (deviceInfo.version.sdkInt >= 33) {
        // Android 13 이상에서는 MANAGE_EXTERNAL_STORAGE 권한 필요
        await Permission.manageExternalStorage.request();
        hasPermission = await Permission.manageExternalStorage.isGranted;
      } else {
        // Android 12 이하
        await Permission.storage.request();
        hasPermission = await Permission.storage.isGranted;
      }

      if (!hasPermission) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return false;
      }

      // 2. 저장 경로 설정
      String downloadPath;
      if (deviceInfo.version.sdkInt >= 33) {
        downloadPath = '/storage/emulated/0/Download/서현이일기';
      } else {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          if (context.mounted) {
            _showErrorDialog(context, '저장소 접근에 실패했습니다.');
          }
          return false;
        }
        downloadPath = externalDir.path.replaceAll(
          RegExp(r'Android/data/[^/]+/files'),
          'Download/서현이일기',
        );
      }

      // 3. 디렉토리 생성
      final saveDir = Directory(downloadPath);
      try {
        if (!await saveDir.exists()) {
          await saveDir.create(recursive: true);
        }
      } catch (e) {
        print('Directory creation failed: $e');
        if (context.mounted) {
          _showErrorDialog(context, '폴더 생성에 실패했습니다.');
        }
        return false;
      }

      // 4. 파일 생성 및 저장
      final now = DateTime.now();
      final fileName = 'diary_backup_${now.year}${now.month}${now.day}.json';
      final file = File('$downloadPath/$fileName');

      // 5. 데이터 준비
      final diaryData = await loadDiary();
      if (diaryData.entries.isEmpty) {
        if (context.mounted) {
          _showErrorDialog(context, '저장할 일기 데이터가 없습니다.');
        }
        return false;
      }

      // 6. 파일 저장
      try {
        await file.writeAsString(
          diaryData.toJsonString(),
          flush: true,
          mode: FileMode.write,
        );
      } catch (e) {
        print('File write failed: $e');
        if (context.mounted) {
          _showErrorDialog(context, '파일 저장에 실패했습니다.\n$e');
        }
        return false;
      }

      // 7. 성공 메시지
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('백업 파일이 저장되었습니다:\n${file.path}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      return true;
    } catch (e) {
      print('Export failed: $e');
      if (context.mounted) {
        _showErrorDialog(context, '저장 중 오류가 발생했습니다.\n$e');
      }
      return false;
    }
  }

  // 권한 거부 다이얼로그
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('파일 저장을 위해 저장소 접근 권한이 필요합니다.\n\n설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  // 오류 다이얼로그
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
} 