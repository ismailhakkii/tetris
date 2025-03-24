import 'dart:math';
import 'models/game_cell.dart';
import 'validation/validation_rules.dart';

enum GameDifficulty {
  easy,   // 40 dolu hücre
  medium, // 30 dolu hücre
  hard,   // 20 dolu hücre
}

class GameEngine {
  final ValidationRule validator;
  late List<List<GameCell>> grid;
  late List<List<int>> solution;
  int remainingLives = 3;
  int score = 0;
  int comboCounter = 0;
  int multiplier = 1;
  bool isGameOver = false;
  bool isGameWon = false;
  
  GameEngine({
    List<ValidationRule>? rules,
  }) : validator = CompositeValidationRule(
         rules ?? [
           RowValidationRule(),
           ColumnValidationRule(),
           BlockValidationRule(),
         ]
       );
  
  void newGame(GameDifficulty difficulty) {
    // Yeni oyunu başlat
    _generateSudoku(difficulty);
    remainingLives = 3;
    score = 0;
    comboCounter = 0;
    multiplier = 1;
    isGameOver = false;
    isGameWon = false;
  }
  
  void _generateSudoku(GameDifficulty difficulty) {
    // Çözümü oluştur
    solution = _generateSolution();
    
    // Zorluk seviyesine göre dolu hücre sayısı
    int filledCells;
    switch (difficulty) {
      case GameDifficulty.easy:
        filledCells = 40;
        break;
      case GameDifficulty.medium:
        filledCells = 30;
        break;
      case GameDifficulty.hard:
        filledCells = 20;
        break;
    }
    
    // Başlangıç ızgarasını oluştur
    grid = List.generate(9, (row) => 
      List.generate(9, (col) => 
        GameCell(row: row, col: col)
      )
    );
    
    // Rastgele hücreleri doldur
    var rng = Random();
    int cellsFilled = 0;
    
    while (cellsFilled < filledCells) {
      int row = rng.nextInt(9);
      int col = rng.nextInt(9);
      
      if (grid[row][col].isEmpty) {
        grid[row][col] = GameCell(
          row: row,
          col: col,
          value: solution[row][col],
          state: CellState.fixed,
        );
        cellsFilled++;
      }
    }
  }
  
  List<List<int>> _generateSolution() {
    // Basit sudoku çözüm matrisi oluştur
    // Gerçek uygulamada backtracking algoritması kullanılabilir
    var result = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonal(result);
    _solveSudoku(result, 0, 0);
    return result;
  }
  
  void _fillDiagonal(List<List<int>> grid) {
    // Köşegen 3x3 kutuları doldur
    for (int i = 0; i < 9; i += 3) {
      _fillBox(grid, i, i);
    }
  }
  
  void _fillBox(List<List<int>> grid, int row, int col) {
    var rng = Random();
    List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    nums.shuffle(rng);
    
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        grid[row + i][col + j] = nums[index++];
      }
    }
  }
  
  bool _solveSudoku(List<List<int>> grid, int row, int col) {
    // Son hücreye geldiyse çözüm tamamlanmıştır
    if (row == 8 && col == 9) return true;
    
    // Sütun sonuna gelindiyse bir alt satıra geç
    if (col == 9) {
      row++;
      col = 0;
    }
    
    // Hücre zaten doluysa bir sonraki hücreye geç
    if (grid[row][col] != 0) {
      return _solveSudoku(grid, row, col + 1);
    }
    
    // 1-9 arası rakamları dene
    for (int num = 1; num <= 9; num++) {
      // Rakam geçerliyse yerleştir
      if (_isSafe(grid, row, col, num)) {
        grid[row][col] = num;
        
        // Rekürsif olarak devam et
        if (_solveSudoku(grid, row, col + 1)) {
          return true;
        }
        
        // Çözüm bulunamadıysa bu rakam çalışmıyor, sıfırla (backtrack)
        grid[row][col] = 0;
      }
    }
    return false; // Çözüm bulunamadı
  }
  
  bool _isSafe(List<List<int>> grid, int row, int col, int num) {
    // Satırda aynı rakam var mı?
    for (int c = 0; c < 9; c++) {
      if (grid[row][c] == num) return false;
    }
    
    // Sütunda aynı rakam var mı?
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }
    
    // 3x3 bloğunda aynı rakam var mı?
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (grid[startRow + r][startCol + c] == num) return false;
      }
    }
    
    return true; // Güvenli
  }
  
  bool makeMove(int row, int col, int value) {
    if (isGameOver || isGameWon) return false;
    
    // Sabit hücrelere hamle yapılamaz
    if (grid[row][col].isFixed) return false;
    
    // Hamle geçerli mi kontrol et
    bool isValid = validator.isValid(row, col, value, grid);
    
    if (isValid) {
      // Doğru hamle
      grid[row][col] = GameCell(
        row: row,
        col: col,
        value: value,
        state: CellState.valid,
      );
      
      // Skor hesapla
      _calculateScore(row, col);
      
      // Oyun kazanıldı mı kontrol et
      _checkWinCondition();
      
      return true;
    } else {
      // Yanlış hamle
      grid[row][col] = GameCell(
        row: row,
        col: col,
        value: value,
        state: CellState.invalid,
      );
      
      // Can azalt
      remainingLives--;
      comboCounter = 0;
      multiplier = 1;
      
      // Oyun bitti mi kontrol et
      if (remainingLives <= 0) {
        isGameOver = true;
      }
      
      return false;
    }
  }
  
  void _calculateScore(int row, int col) {
    // Temel puan
    int addedScore = 10 * multiplier;
    
    // Combo sayacını artır
    comboCounter++;
    
    // 5 ardışık doğru hamlede çarpan artar (max 4x)
    if (comboCounter % 5 == 0 && multiplier < 4) {
      multiplier++;
    }
    
    // Satır tamamlandı mı?
    bool rowCompleted = true;
    for (int c = 0; c < 9; c++) {
      if (grid[row][c].isEmpty) {
        rowCompleted = false;
        break;
      }
    }
    
    if (rowCompleted) {
      addedScore += 30 * multiplier;
    }
    
    // Sütun tamamlandı mı?
    bool colCompleted = true;
    for (int r = 0; r < 9; r++) {
      if (grid[r][col].isEmpty) {
        colCompleted = false;
        break;
      }
    }
    
    if (colCompleted) {
      addedScore += 30 * multiplier;
    }
    
    // 3x3 blok tamamlandı mı?
    int blockRow = (row ~/ 3) * 3;
    int blockCol = (col ~/ 3) * 3;
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
    
    if (blockCompleted) {
      addedScore += 50 * multiplier;
    }
    
    // Toplam skoru güncelle
    score += addedScore;
  }
  
  void _checkWinCondition() {
    // Tüm hücreler dolu mu kontrol et
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c].isEmpty) {
          return; // Oyun henüz bitmedi
        }
      }
    }
    isGameWon = true;
  }
  
  // Bir rakamın kaç kez kullanıldığını hesapla
  int getNumberCount(int value) {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c].value == value) {
          count++;
        }
      }
    }
    return count;
  }
}