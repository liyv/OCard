import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/speech_service.dart';

/// 词汇学习卡片组件
class VocabCard extends StatefulWidget {
  final VocabularyItem vocab;
  final VoidCallback? onLearned;

  const VocabCard({
    super.key,
    required this.vocab,
    this.onLearned,
  });

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard> {
  final SpeechService _speechService = SpeechService();
  bool _showDefinition = false;
  bool _isPlaying = false;

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _playEnglish() async {
    setState(() => _isPlaying = true);
    await _speechService.speakEnglish(widget.vocab.englishWord);
    setState(() => _isPlaying = false);
  }

  Future<void> _playJapanese() async {
    setState(() => _isPlaying = true);
    await _speechService.speakJapanese(widget.vocab.japaneseWord);
    setState(() => _isPlaying = false);
  }

  Future<void> _playExampleEn() async {
    await _speechService.speakEnglish(widget.vocab.exampleSentenceEn);
  }

  Future<void> _playExampleJp() async {
    await _speechService.speakJapanese(widget.vocab.exampleSentenceJp);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 物品图标和名称
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.vocab.imageUrl,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.vocab.item,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 英文单词
            _buildLanguageSection(
              title: '🇺🇸 English',
              word: widget.vocab.englishWord,
              onPlay: _playEnglish,
              isPlaying: _isPlaying,
            ),
            const SizedBox(height: 16),
            
            // 日文单词
            _buildLanguageSection(
              title: '🇯🇵 日本語',
              word: '${widget.vocab.japaneseWord}\n${widget.vocab.japaneseReading}',
              onPlay: _playJapanese,
              isPlaying: _isPlaying,
            ),
            const Divider(height: 32),
            
            // 例句部分
            _buildExampleSection(
              sentence: widget.vocab.exampleSentenceEn,
              onPlay: _playExampleEn,
              label: 'EN',
            ),
            const SizedBox(height: 12),
            _buildExampleSection(
              sentence: widget.vocab.exampleSentenceJp,
              reading: widget.vocab.exampleSentenceJpReading,
              onPlay: _playExampleJp,
              label: 'JP',
            ),
            const SizedBox(height: 16),
            
            // 释义按钮
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _showDefinition = !_showDefinition);
              },
              icon: Icon(_showDefinition ? Icons.visibility_off : Icons.visibility),
              label: Text(_showDefinition ? '隐藏释义' : '查看释义'),
            ),
            
            if (_showDefinition) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.vocab.definition,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 已学习按钮
            ElevatedButton(
              onPressed: widget.onLearned,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '✓ 已学习',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection({
    required String title,
    required String word,
    required VoidCallback onPlay,
    required bool isPlaying,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: isPlaying ? null : onPlay,
          icon: Icon(
            isPlaying ? Icons.volume_up : Icons.volume_outlined,
            color: isPlaying ? Colors.blue : Colors.grey,
          ),
          iconSize: 32,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                word,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleSection({
    required String sentence,
    String? reading,
    required VoidCallback onPlay,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: label == 'EN' ? Colors.blue.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: label == 'EN' ? Colors.blue.shade700 : Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sentence,
                style: const TextStyle(fontSize: 15),
              ),
              if (reading != null) ...[
                const SizedBox(height: 4),
                Text(
                  reading,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: onPlay,
          icon: const Icon(Icons.volume_outlined),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
