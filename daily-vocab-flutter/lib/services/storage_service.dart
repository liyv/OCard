import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';

/// 本地存储服务 - 使用 SharedPreferences 持久化学习数据
class StorageService {
  static const String _learningRecordsKey = 'learning_records';
  static const String _dailyProgressKey = 'daily_progress';
  static const String _lastOpenDateKey = 'last_open_date';

  /// 保存学习记录
  Future<void> saveLearningRecord(LearningRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await _getAllLearningRecords();
    
    // 更新或添加记录
    final existingIndex = records.indexWhere((r) => r.vocabId == record.vocabId);
    if (existingIndex >= 0) {
      records[existingIndex] = record;
    } else {
      records.add(record);
    }
    
    final recordsJson = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_learningRecordsKey, recordsJson);
  }

  /// 获取所有学习记录
  Future<List<LearningRecord>> getAllLearningRecords() async {
    return await _getAllLearningRecords();
  }

  /// 获取特定词汇的学习记录
  Future<LearningRecord?> getLearningRecord(String vocabId) async {
    final records = await _getAllLearningRecords();
    try {
      return records.firstWhere((r) => r.vocabId == vocabId);
    } catch (e) {
      return null;
    }
  }

  /// 删除学习记录
  Future<void> deleteLearningRecord(String vocabId) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await _getAllLearningRecords();
    records.removeWhere((r) => r.vocabId == vocabId);
    
    final recordsJson = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_learningRecordsKey, recordsJson);
  }

  /// 保存每日进度
  Future<void> saveDailyProgress(DailyProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progresses = await _getAllDailyProgresses();
    
    // 更新或添加该日期的进度
    final existingIndex = progresses.indexWhere(
      (p) => p.date.toIso8601String().split('T')[0] == 
             progress.date.toIso8601String().split('T')[0]
    );
    if (existingIndex >= 0) {
      progresses[existingIndex] = progress;
    } else {
      progresses.add(progress);
    }
    
    final progressJson = progresses.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_dailyProgressKey, progressJson);
  }

  /// 获取所有每日进度
  Future<List<DailyProgress>> getAllDailyProgresses() async {
    return await _getAllDailyProgresses();
  }

  /// 获取总学习统计
  Future<Map<String, int>> getTotalStats() async {
    final records = await _getAllLearningRecords();
    final totalLearned = records.length;
    final totalReviews = records.fold<int>(
      0, 
      (sum, r) => sum + r.reviewCount
    );
    final masteredCount = records.where(
      (r) => r.masteryLevel == MasteryLevel.mastered
    ).length;
    
    return {
      'totalLearned': totalLearned,
      'totalReviews': totalReviews,
      'masteredCount': masteredCount,
    };
  }

  /// 检查是否需要重置每日进度（新的一天）
  Future<bool> isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastOpenDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastDate == null || lastDate != today) {
      await prefs.setString(_lastOpenDateKey, today);
      return true;
    }
    return false;
  }

  /// 清除所有数据
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_learningRecordsKey);
    await prefs.remove(_dailyProgressKey);
  }

  // Helper methods
  Future<List<LearningRecord>> _getAllLearningRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(_learningRecordsKey) ?? [];
    return recordsJson
        .map((json) => LearningRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<DailyProgress>> _getAllDailyProgresses() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getStringList(_dailyProgressKey) ?? [];
    return progressJson
        .map((json) => DailyProgress.fromJson(jsonDecode(json)))
        .toList();
  }
}
