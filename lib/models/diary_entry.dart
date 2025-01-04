import 'dart:convert';

class DiaryEntry {
  final String id;          // 고유 ID
  final String date;        // 날짜
  final String content;     // 일기 내용
  final DateTime createdAt; // 작성 시간
  final DateTime updatedAt; // 수정 시간

  DiaryEntry({
    String? id,
    required this.date,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'],
    date: json['date'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class DiaryData {
  final List<DiaryEntry> entries;
  final String version;     // 데이터 버전
  final String appName;     // 앱 이름
  final DateTime lastSync;  // 마지막 동기화 시간

  DiaryData({
    required this.entries,
    this.version = '1.0.0',
    this.appName = '서현이일기',
    DateTime? lastSync,
  }) : this.lastSync = lastSync ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'version': version,
    'appName': appName,
    'lastSync': lastSync.toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory DiaryData.fromJson(Map<String, dynamic> json) => DiaryData(
    entries: (json['entries'] as List? ?? [])
        .map((e) => DiaryEntry.fromJson(e))
        .toList(),
    version: json['version'] ?? '1.0.0',
    appName: json['appName'] ?? '서현이일기',
    lastSync: json['lastSync'] != null 
        ? DateTime.parse(json['lastSync'])
        : DateTime.now(),
  );

  String toJsonString() => jsonEncode(toJson());
} 