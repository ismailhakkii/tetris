import 'package:hive/hive.dart';

class ScoreCalculator {
  final Box scoreBox;
  
  ScoreCalculator({Box? scoreBox}) 
    : this.scoreBox = scoreBox ?? Hive.box('scoreBox');
  
  // Yüksek skorları kaydet
  Future<void> saveScore(int score, String difficulty) async {
    final List<dynamic> highScores = scoreBox.get('highScores_$difficulty', defaultValue: []) ?? [];
    
    highScores.add({
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
    
    // Skorları sırala
    highScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    // İlk 10 skoru sakla
    final topScores = highScores.take(10).toList();
    
    await scoreBox.put('highScores_$difficulty', topScores);
  }
  
  // Yüksek skorları getir
  List<Map<String, dynamic>> getHighScores(String difficulty) {
    final List<dynamic> highScores = scoreBox.get('highScores_$difficulty', defaultValue: []) ?? [];
    return highScores.cast<Map<String, dynamic>>();
  }
}