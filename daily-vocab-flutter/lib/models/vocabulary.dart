/// 词汇数据模型
class VocabularyItem {
  final String id;
  final String item; // 日常物品（中文）
  final String imageUrl; // 图片 URL 或 emoji
  final String englishWord;
  final String japaneseWord;
  final String japaneseReading; // 假名读音
  final String exampleSentenceEn;
  final String exampleSentenceJp;
  final String exampleSentenceJpReading;
  final String definition;

  VocabularyItem({
    required this.id,
    required this.item,
    required this.imageUrl,
    required this.englishWord,
    required this.japaneseWord,
    required this.japaneseReading,
    required this.exampleSentenceEn,
    required this.exampleSentenceJp,
    required this.exampleSentenceJpReading,
    required this.definition,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'imageUrl': imageUrl,
      'englishWord': englishWord,
      'japaneseWord': japaneseWord,
      'japaneseReading': japaneseReading,
      'exampleSentenceEn': exampleSentenceEn,
      'exampleSentenceJp': exampleSentenceJp,
      'exampleSentenceJpReading': exampleSentenceJpReading,
      'definition': definition,
    };
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      item: json['item'] as String,
      imageUrl: json['imageUrl'] as String,
      englishWord: json['englishWord'] as String,
      japaneseWord: json['japaneseWord'] as String,
      japaneseReading: json['japaneseReading'] as String,
      exampleSentenceEn: json['exampleSentenceEn'] as String,
      exampleSentenceJp: json['exampleSentenceJp'] as String,
      exampleSentenceJpReading: json['exampleSentenceJpReading'] as String,
      definition: json['definition'] as String,
    );
  }
}

/// 学习记录模型
class LearningRecord {
  final String vocabId;
  final DateTime firstLearned;
  final DateTime lastReviewed;
  final int reviewCount;
  final double easeFactor; // 间隔重复难度系数 (默认 2.5)
  final int intervalDays; // 下次复习间隔天数
  final MasteryLevel masteryLevel;

  LearningRecord({
    required this.vocabId,
    required this.firstLearned,
    required this.lastReviewed,
    required this.reviewCount,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.masteryLevel = MasteryLevel.newWord,
  });

  Map<String, dynamic> toJson() {
    return {
      'vocabId': vocabId,
      'firstLearned': firstLearned.toIso8601String(),
      'lastReviewed': lastReviewed.toIso8601String(),
      'reviewCount': reviewCount,
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'masteryLevel': masteryLevel.index,
    };
  }

  factory LearningRecord.fromJson(Map<String, dynamic> json) {
    return LearningRecord(
      vocabId: json['vocabId'] as String,
      firstLearned: DateTime.parse(json['firstLearned'] as String),
      lastReviewed: DateTime.parse(json['lastReviewed'] as String),
      reviewCount: json['reviewCount'] as int,
      easeFactor: (json['easeFactor'] as num).toDouble(),
      intervalDays: json['intervalDays'] as int,
      masteryLevel: MasteryLevel.values[json['masteryLevel'] as int],
    );
  }
}

/// 掌握程度枚举
enum MasteryLevel {
  newWord,       // 新词
  learning,      // 学习中
  familiar,      // 熟悉
  mastered,      // 已掌握
}

/// 每日学习进度
class DailyProgress {
  final DateTime date;
  final int wordsLearned;
  final int wordsReviewed;
  final List<String> learnedVocabIds;

  DailyProgress({
    required this.date,
    this.wordsLearned = 0,
    this.wordsReviewed = 0,
    required this.learnedVocabIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'wordsLearned': wordsLearned,
      'wordsReviewed': wordsReviewed,
      'learnedVocabIds': learnedVocabIds,
    };
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse('${json['date']}T00:00:00'),
      wordsLearned: json['wordsLearned'] as int? ?? 0,
      wordsReviewed: json['wordsReviewed'] as int? ?? 0,
      learnedVocabIds: List<String>.from(json['learnedVocabIds'] ?? []),
    );
  }
}
