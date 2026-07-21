import 'dart:math';
import '../models/vocabulary.dart';

/// 词汇数据服务 - 提供每日词汇数据
class VocabularyService {
  // 日常物品词汇库
  static final List<VocabularyItem> _vocabularyList = [
    VocabularyItem(
      id: 'water_bottle',
      item: '水杯',
      imageUrl: '🥤',
      englishWord: 'Water Bottle',
      japaneseWord: '水筒',
      japaneseReading: 'すいとう (suitou)',
      exampleSentenceEn: 'I always carry a water bottle with me.',
      exampleSentenceJp: '私はいつも水筒を持ち歩いています。',
      exampleSentenceJpReading: 'わたしは いつも すいとうを もちあるいています。',
      definition: 'A container for holding water or other drinks.',
    ),
    VocabularyItem(
      id: 'book',
      item: '书本',
      imageUrl: '📚',
      englishWord: 'Book',
      japaneseWord: '本',
      japaneseReading: 'ほん (hon)',
      exampleSentenceEn: 'She is reading an interesting book.',
      exampleSentenceJp: '彼女は面白い本を読んでいます。',
      exampleSentenceJpReading: 'かのじょは おもしろい ほんを よんでいます。',
      definition: 'A written or printed work consisting of pages.',
    ),
    VocabularyItem(
      id: 'smartphone',
      item: '手机',
      imageUrl: '📱',
      englishWord: 'Smartphone',
      japaneseWord: 'スマートフォン',
      japaneseReading: 'すまーとふぉん (sumātofon)',
      exampleSentenceEn: 'He uses his smartphone to check emails.',
      exampleSentenceJp: '彼はスマートフォンでメールをチェックします。',
      exampleSentenceJpReading: 'かれは すまーとふぉんで めーるを ちぇっくします。',
      definition: 'A mobile phone with advanced computing capabilities.',
    ),
    VocabularyItem(
      id: 'desk',
      item: '桌子',
      imageUrl: '🪑',
      englishWord: 'Desk',
      japaneseWord: '机',
      japaneseReading: 'つくえ (tsukue)',
      exampleSentenceEn: 'Please put the documents on the desk.',
      exampleSentenceJp: '書類を机に置いてください。',
      exampleSentenceJpReading: 'しょるいを つくえに おいてください。',
      definition: 'A piece of furniture with a flat surface for writing.',
    ),
    VocabularyItem(
      id: 'chair',
      item: '椅子',
      imageUrl: '🪑',
      englishWord: 'Chair',
      japaneseWord: '椅子',
      japaneseReading: 'いす (isu)',
      exampleSentenceEn: 'Sit down on the chair, please.',
      exampleSentenceJp: '椅子に座ってください。',
      exampleSentenceJpReading: 'いすに すわってください。',
      definition: 'A separate seat for one person.',
    ),
    VocabularyItem(
      id: 'computer',
      item: '电脑',
      imageUrl: '💻',
      englishWord: 'Computer',
      japaneseWord: 'パソコン',
      japaneseReading: 'ぱそこん (pasokon)',
      exampleSentenceEn: 'I work on my computer every day.',
      exampleSentenceJp: '私は毎日パソコンで仕事をします。',
      exampleSentenceJpReading: 'わたしは まいにち ぱそこんで しごとを します。',
      definition: 'An electronic device for storing and processing data.',
    ),
    VocabularyItem(
      id: 'pen',
      item: '笔',
      imageUrl: '🖊️',
      englishWord: 'Pen',
      japaneseWord: 'ペン',
      japaneseReading: 'ぺん (pen)',
      exampleSentenceEn: 'Can I borrow your pen?',
      exampleSentenceJp: 'ペンを貸してもらえますか？',
      exampleSentenceJpReading: 'ぺんを かしてもらえますか？',
      definition: 'An instrument for writing or drawing with ink.',
    ),
    VocabularyItem(
      id: 'backpack',
      item: '背包',
      imageUrl: '🎒',
      englishWord: 'Backpack',
      japaneseWord: 'リュック',
      japaneseReading: 'りゅっく (ryukku)',
      exampleSentenceEn: 'She carries her laptop in her backpack.',
      exampleSentenceJp: '彼女はリュックにノートパソコンを入れています。',
      exampleSentenceJpReading: 'かのじょは りゅっくに のーとぱそこんを いれています。',
      definition: 'A bag carried on the back, secured with two straps.',
    ),
    VocabularyItem(
      id: 'coffee_cup',
      item: '咖啡杯',
      imageUrl: '☕',
      englishWord: 'Coffee Cup',
      japaneseWord: 'コーヒーカップ',
      japaneseReading: 'こーひーかっぷ (kōhī kappu)',
      exampleSentenceEn: 'She enjoys her morning coffee from her favorite cup.',
      exampleSentenceJp: '彼女はお気に入りのカップで朝のコーヒーを楽しみます。',
      exampleSentenceJpReading: 'かのじょは おきにいりの かっぷで あさの こーひーを たのしみます。',
      definition: 'A small cup used for drinking coffee.',
    ),
    VocabularyItem(
      id: 'headphones',
      item: '耳机',
      imageUrl: '🎧',
      englishWord: 'Headphones',
      japaneseWord: 'ヘッドフォン',
      japaneseReading: 'へっどふぉん (heddofon)',
      exampleSentenceEn: 'He listens to music with headphones.',
      exampleSentenceJp: '彼はヘッドフォンで音楽を聴きます。',
      exampleSentenceJpReading: 'かれは へっどふぉんで おんがくを ききます。',
      definition: 'A pair of earpieces connected by a band over the head.',
    ),
    VocabularyItem(
      id: 'umbrella',
      item: '雨伞',
      imageUrl: '☂️',
      englishWord: 'Umbrella',
      japaneseWord: '傘',
      japaneseReading: 'かさ (kasa)',
      exampleSentenceEn: 'Don\'t forget to take your umbrella, it\'s raining.',
      exampleSentenceJp: '忘れないで傘を持って行ってください、雨が降っています。',
      exampleSentenceJpReading: 'わすれないで かさを もっていってください、あめが ふっています。',
      definition: 'A device for protection against rain or sun.',
    ),
    VocabularyItem(
      id: 'watch',
      item: '手表',
      imageUrl: '⌚',
      englishWord: 'Watch',
      japaneseWord: '時計',
      japaneseReading: 'とけい (tokei)',
      exampleSentenceEn: 'What time is it on your watch?',
      exampleSentenceJp: 'あなたの時計は今何時ですか？',
      exampleSentenceJpReading: 'あなたの とけいは いま なんじですか？',
      definition: 'A small timepiece worn on the wrist.',
    ),
  ];

  /// 获取所有词汇
  List<VocabularyItem> getAllVocabulary() {
    return List.unmodifiable(_vocabularyList);
  }

  /// 根据 ID 获取词汇
  VocabularyItem? getVocabularyById(String id) {
    try {
      return _vocabularyList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取今日推荐词汇（基于日期选择）
  List<VocabularyItem> getDailyVocabulary({int count = 5}) {
    final now = DateTime.now();
    final seed = now.year * 1000 + now.month * 30 + now.day;
    
    // 简单的伪随机选择
    final shuffled = List.of(_vocabularyList);
    shuffled.shuffle(Random(seed));
    
    return shuffled.take(count).toList();
  }

  /// 搜索词汇
  List<VocabularyItem> searchVocabulary(String query) {
    final lowerQuery = query.toLowerCase();
    return _vocabularyList.where((item) =>
      item.item.contains(query) ||
      item.englishWord.toLowerCase().contains(lowerQuery) ||
      item.japaneseWord.contains(query) ||
      item.definition.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
