import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../data/vocabulary_data.dart';
import '../services/storage_service.dart';
import '../widgets/vocab_card.dart';

/// 主学习页面 - 显示每日词汇卡片
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VocabularyService _vocabService = VocabularyService();
  final StorageService _storageService = StorageService();
  
  List<VocabularyItem> _dailyVocabs = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVocabs();
  }

  Future<void> _loadDailyVocabs() async {
    setState(() => _isLoading = true);
    // 获取今日词汇（这里简化为获取所有词汇的前 5 个）
    final vocabs = _vocabService.getDailyVocabulary(count: 5);
    setState(() {
      _dailyVocabs = vocabs;
      _isLoading = false;
    });
  }

  Future<void> _markAsLearned() async {
    if (_dailyVocabs.isEmpty) return;
    
    final currentVocab = _dailyVocabs[_currentIndex];
    
    // 创建学习记录
    final record = LearningRecord(
      vocabId: currentVocab.id,
      firstLearned: DateTime.now(),
      lastReviewed: DateTime.now(),
      reviewCount: 1,
      masteryLevel: MasteryLevel.learning,
    );
    
    await _storageService.saveLearningRecord(record);
    
    // 更新每日进度
    final today = DateTime.now();
    final progress = DailyProgress(
      date: today,
      wordsLearned: 1,
      learnedVocabIds: [currentVocab.id],
    );
    await _storageService.saveDailyProgress(progress);
    
    // 移动到下一个卡片
    if (_currentIndex < _dailyVocabs.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 今日学习完成!'),
        content: const Text('太棒了！你已经完成了今天的所有词汇学习。明天继续加油！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadDailyVocabs(); // 重新加载
            },
            child: const Text('再学一遍'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _currentIndex = 0);
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

    if (_dailyVocabs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无词汇数据', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyVocabs,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('每日词汇学习'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyVocabs,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度指示器
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '进度：${_currentIndex + 1} / ${_dailyVocabs.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _dailyVocabs.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          // 词汇卡片
          Expanded(
            child: PageView.builder(
              itemCount: _dailyVocabs.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return VocabCard(
                  vocab: _dailyVocabs[index],
                  onLearned: _markAsLearned,
                );
              },
            ),
          ),
          
          // 底部提示
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '点击发音按钮听单词和例句，点击"查看释义"了解详细含义',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
