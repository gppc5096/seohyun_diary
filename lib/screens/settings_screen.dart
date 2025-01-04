import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seohyun_diary/services/diary_service.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPasswordEnabled = false;
  String? _currentPassword;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPasswordSettings();
  }

  Future<void> _loadPasswordSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPasswordEnabled = prefs.getBool('password_enabled') ?? false;
      _currentPassword = prefs.getString('password');
    });
  }

  Future<void> _togglePassword(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      // 비밀번호 설정 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('비밀번호 설정'),
          content: TextField(
            controller: _passwordController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: '4자리 숫자를 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isPasswordEnabled = false;
                });
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (_passwordController.text.length == 4) {
                  await prefs.setString('password', _passwordController.text);
                  await prefs.setBool('password_enabled', true);
                  setState(() {
                    _isPasswordEnabled = true;
                    _currentPassword = _passwordController.text;
                  });
                  _passwordController.clear();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호가 설정되었습니다')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('4자리 숫자를 입력해주세요')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 비밀번호 해제
      await prefs.setBool('password_enabled', false);
      await prefs.remove('password');
      setState(() {
        _isPasswordEnabled = false;
        _currentPassword = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 해제되었습니다')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final success = await DiaryService.exportToSelectedLocation(context);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 권한이 필요합니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업 중 오류가 발생했습니다')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      final success = await DiaryService.restoreFromBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '데이터가 복원되었습니다' : '데이터 복원이 취소되었습니다'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복원 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text('비밀번호 설정'),
                  subtitle: Text(_isPasswordEnabled ? '비밀번호: $_currentPassword' : '비밀번호 없음'),
                  value: _isPasswordEnabled,
                  onChanged: _togglePassword,
                ),
                const Divider(),
                ListTile(
                  title: const Text('데이터 내보내기'),
                  subtitle: const Text('일기 데이터를 파일로 저장'),
                  trailing: const Icon(Icons.file_download),
                  onTap: _exportData,
                ),
                ListTile(
                  title: const Text('데이터 가져오기'),
                  subtitle: const Text('저장된 데이터 파일에서 복원'),
                  trailing: const Icon(Icons.file_upload),
                  onTap: _importData,
                ),
                const Divider(),
                const ListTile(
                  title: Text('버전 정보'),
                  subtitle: Text('2015.12.05'),
                ),
                const ListTile(
                  title: Text('개발자 정보'),
                  subtitle: Text('사랑하는 서현에게 주는 할아버지 선물'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              border: const Border(
                top: BorderSide(color: Colors.blue, width: 0.5),
              ),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    '서현아! 매일 1가지씩 감사하는 말을 하고 살거라!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 서현이일기. All rights reserved.',
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
    _passwordController.dispose();
    super.dispose();
  }
} 