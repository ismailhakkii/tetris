import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_engine.dart';
import '../../domain/models/game_cell.dart';
import '../../domain/score_calculator.dart';

final gameViewModelProvider = ChangeNotifierProvider((ref) {
  return GameViewModel(
    engine: GameEngine(),
    scorer: ScoreCalculator(),
  );
});

class GameViewModel extends ChangeNotifier {
  final GameEngine engine;
  final ScoreCalculator scorer;
  GameDifficulty _difficulty = GameDifficulty.medium;
  
  // Animasyon durumları
  int? _lastInvalidRow;
  int? _lastInvalidCol;
  bool _shakingCell = false;
  
  // Tamamlanan bölümleri takip etme
  Set<int> _completedRows = {};
  Set<int> _completedCols = {};
  Set<String> _completedBlocks = {};
  
  // Animasyon için cell offset'leri
  Map<String, Offset> _cellOffsets = {};
  
  GameViewModel({
    required this.engine,
    required this.scorer,
  }) {
    newGame();
  }
  
  // Getters
  List<List<GameCell>> get grid => engine.grid;
  int get score => engine.score;
  int get remainingLives => engine.remainingLives;
  int get multiplier => engine.multiplier;
  bool get isGameOver => engine.isGameOver;
  bool get isGameWon => engine.isGameWon;
  GameDifficulty get difficulty => _difficulty;
  int? get lastInvalidRow => _lastInvalidRow;
  int? get lastInvalidCol => _lastInvalidCol;
  bool get isShakingCell => _shakingCell;
  
  // Cell offset'i kaydet (animasyon için)
  void setCellOffset(int row, int col, Offset offset) {
    _cellOffsets['$row-$col'] = offset;
  }
  
  // Hamle yap
  void makeMove(int row, int col, int value) {
    bool isValid = engine.makeMove(row, col, value);
    
    if (!isValid) {
      // Geçersiz hamle animasyonu için
      _lastInvalidRow = row;
      _lastInvalidCol = col;
      _shakingCell = true;
      
      // Animasyonu tetikle
      Future.delayed(const Duration(milliseconds: 500), () {
        _shakingCell = false;
        notifyListeners();
      });
    } else {
      // Satır, sütun veya blok tamamlandı mı kontrol et
      checkForCompletions(row, col);
    }
    
    // Oyun bitti veya kazanıldıysa skoru kaydet
    if (engine.isGameOver || engine.isGameWon) {
      String difficultyStr;
      switch (_difficulty) {
        case GameDifficulty.easy:
          difficultyStr = 'easy';
          break;
        case GameDifficulty.medium:
          difficultyStr = 'medium';
          break;
        case GameDifficulty.hard:
          difficultyStr = 'hard';
          break;
      }
      
      scorer.saveScore(engine.score, difficultyStr);
    }
    
    notifyListeners();
  }
  
  // Yeni oyun başlat
  void newGame() {
    engine.newGame(_difficulty);
    _lastInvalidRow = null;
    _lastInvalidCol = null;
    _shakingCell = false;
    _completedRows = {};
    _completedCols = {};
    _completedBlocks = {};
    _cellOffsets = {};
    notifyListeners();
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(GameDifficulty difficulty) {
    _difficulty = difficulty;
    newGame();
  }
  
  // Bir rakamın kaç kez kullanıldığını hesapla
  int getNumberCount(int value) {
    return engine.getNumberCount(value);
  }
  
  // Tamamlanan satır, sütun veya blok kontrol et
  void checkForCompletions(int row, int col) {
    // Satır tamamlandı mı?
    bool rowCompleted = true;
    for (int c = 0; c < 9; c++) {
      if (grid[row][c].isEmpty) {
        rowCompleted = false;
        break;
      }
    }
    
    if (rowCompleted && !_completedRows.contains(row)) {
      _completedRows.add(row);
    }
    
    // Sütun tamamlandı mı?
    bool colCompleted = true;
    for (int r = 0; r < 9; r++) {
      if (grid[r][col].isEmpty) {
        colCompleted = false;
        break;
      }
    }
    
    if (colCompleted && !_completedCols.contains(col)) {
      _completedCols.add(col);
    }
    
    // 3x3 blok tamamlandı mı?
    int blockRow = (row ~/ 3) * 3;
    int blockCol = (col ~/ 3) * 3;
    String blockKey = '$blockRow-$blockCol';
    bool blockCompleted = true;
    
    for (int r = blockRow; r < blockRow + 3; r++) {
      for (int c = blockCol; c < blockCol + 3; c++) {
        if (grid[r][c].isEmpty) {
          blockCompleted = false;
          break;
        }
      }
      if (!blockCompleted) break;
    }
    
    if (blockCompleted && !_completedBlocks.contains(blockKey)) {
      _completedBlocks.add(blockKey);
    }
  }
}