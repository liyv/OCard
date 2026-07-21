import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/storage_service.dart';

/// 历史记录页面 - 显示学习统计和已学单词
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  
  Map<String, int> _stats = {};
  List<LearningRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final stats = await _storageService.getTotalStats();
    final records = await _storageService.getAllLearningRecords();
    
    // 按掌握程度排序
    records.sort((a, b) => b.intervalDays.compareTo(a.intervalDays));
    
    setState(() {
      _stats = stats;
      _records = records;
      _isLoading = false;
    });
  }

  String _getMasteryLevelText(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.mastered:
        return '已掌握';
      case MasteryLevel.familiar:
        return '熟悉';
      case MasteryLevel.learning:
        return '学习中';
      case MasteryLevel.newWord:
        return '新词';
    }
  }

  Color _getMasteryLevelColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.mastered:
        return Colors.green;
      case MasteryLevel.familiar:
        return Colors.blue;
      case MasteryLevel.learning:
        return Colors.orange;
      case MasteryLevel.newWord:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习历史'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 统计卡片
              _buildStatsCard(),
              const SizedBox(height: 24),
              
              // 已学单词列表
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '已学单词',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '共 ${_records.length} 个',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_records.isEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        '还没有学习记录',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      const Text('去学习页面开始学习吧!'),
                    ],
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMasteryLevelColor(record.masteryLevel),
                          child: Text(
                            '${record.intervalDays}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text('单词 ID: ${record.vocabId}'),
                        subtitle: Text(
                          '复习次数：${record.reviewCount} | '
                          '下次复习：${record.intervalDays}天后',
                        ),
                        trailing: Chip(
                          label: Text(
                            _getMasteryLevelText(record.masteryLevel),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getMasteryLevelColor(record.masteryLevel),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '学习统计',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '📚',
                  '${_stats['totalLearned'] ?? 0}',
                  '已学单词',
                ),
                _buildStatItem(
                  '🔄',
                  '${_stats['totalReviews'] ?? 0}',
                  '总复习数',
                ),
                _buildStatItem(
                  '⭐',
                  '${_stats['masteredCount'] ?? 0}',
                  '已掌握',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
