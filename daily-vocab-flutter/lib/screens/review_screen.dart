import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../data/vocabulary_data.dart';
import '../services/storage_service.dart';

/// 复习页面 - 基于间隔重复算法的复习系统
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final VocabularyService _vocabService = VocabularyService();
  final StorageService _storageService = StorageService();
  
  List<VocabularyItem> _reviewQueue = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showAnswer = false;
  LearningRecord? _currentRecord;

  @override
  void initState() {
    super.initState();
    _loadReviewQueue();
  }

  Future<void> _loadReviewQueue() async {
    setState(() => _isLoading = true);
    
    final allRecords = await _storageService.getAllLearningRecords();
    final now = DateTime.now();
    
    // 筛选需要复习的词汇（间隔重复算法）
    final dueVocabs = <VocabularyItem>[];
    
    for (final record in allRecords) {
      final nextReviewDate = record.lastReviewed.add(
        Duration(days: record.intervalDays)
      );
      
      if (nextReviewDate.isBefore(now) || nextReviewDate.isAtSameMomentAs(now)) {
        final vocab = _vocabService.getVocabularyById(record.vocabId);
        if (vocab != null) {
          dueVocabs.add(vocab);
        }
      }
    }
    
    setState(() {
      _reviewQueue = dueVocabs;
      _currentIndex = 0;
      _isLoading = false;
    });
  }

  void _updateReviewResult(int quality) {
    if (_reviewQueue.isEmpty || _currentIndex >= _reviewQueue.length) return;
    
    final currentVocab = _reviewQueue[_currentIndex];
    
    // SM-2 间隔重复算法简化版
    double newEaseFactor = (_currentRecord?.easeFactor ?? 2.5) + 
                          (0.1 * (5 - quality));
    if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    
    int newInterval;
    if (quality >= 3) {
      if ((_currentRecord?.reviewCount ?? 0) == 0) {
        newInterval = 1;
      } else if ((_currentRecord?.reviewCount ?? 0) == 1) {
        newInterval = 6;
      } else {
        newInterval = ((_currentRecord?.intervalDays ?? 1) * newEaseFactor).round();
      }
    } else {
      newInterval = 1;
    }
    
    final updatedRecord = LearningRecord(
      vocabId: currentVocab.id,
      firstLearned: _currentRecord?.firstLearned ?? DateTime.now(),
      lastReviewed: DateTime.now(),
      reviewCount: (_currentRecord?.reviewCount ?? 0) + 1,
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      masteryLevel: _getMasteryLevel(newInterval),
    );
    
    _storageService.saveLearningRecord(updatedRecord);
    
    // 移动到下一个
    if (_currentIndex < _reviewQueue.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _currentRecord = null;
      });
    } else {
      _showCompletionDialog();
    }
  }

  MasteryLevel _getMasteryLevel(int intervalDays) {
    if (intervalDays >= 30) return MasteryLevel.mastered;
    if (intervalDays >= 7) return MasteryLevel.familiar;
    if (intervalDays >= 1) return MasteryLevel.learning;
    return MasteryLevel.newWord;
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎊 复习完成!'),
        content: const Text('恭喜你完成了本次复习！继续保持！'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadReviewQueue();
            },
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewQueue.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '太棒了!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('目前没有需要复习的单词'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadReviewQueue,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    final currentVocab = _reviewQueue[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('复习模式'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviewQueue,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度指示
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '复习：${_currentIndex + 1} / ${_reviewQueue.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 物品图标
                      Center(
                        child: Text(
                          currentVocab.imageUrl,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 中文提示
                      Center(
                        child: Text(
                          currentVocab.item,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const Divider(height: 48),
                      
                      if (_showAnswer) ...[
                        // 显示答案
                        _buildWordRow('🇺🇸 English', currentVocab.englishWord),
                        const SizedBox(height: 16),
                        _buildWordRow('🇯🇵 日本語', 
                          '${currentVocab.japaneseWord}\n${currentVocab.japaneseReading}'),
                        const SizedBox(height: 16),
                        _buildWordRow('释义', currentVocab.definition),
                        const SizedBox(height: 24),
                        
                        // 例句
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EN: ${currentVocab.exampleSentenceEn}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'JP: ${currentVocab.exampleSentenceJp}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 评分按钮
                        const Text(
                          '请评价你的记忆程度:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQualityButton(1, '😞', '完全忘记'),
                            _buildQualityButton(2, '😕', '模糊'),
                            _buildQualityButton(3, '😐', '记得一些'),
                            _buildQualityButton(4, '😊', '较好'),
                            _buildQualityButton(5, '🤩', '完美'),
                          ],
                        ),
                      ] else ...[
                        // 隐藏答案，显示提示按钮
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showAnswer = true);
                              // 加载当前词汇的学习记录
                              _storageService.getLearningRecord(currentVocab.id)
                                .then((record) {
                                  setState(() => _currentRecord = record);
                                });
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('显示答案'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordRow(String label, String word) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            word,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityButton(int quality, String emoji, String label) {
    return Column(
      children: [
        IconButton(
          onPressed: () => _updateReviewResult(quality),
          icon: Text(emoji, style: const TextStyle(fontSize: 32)),
          tooltip: label,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
