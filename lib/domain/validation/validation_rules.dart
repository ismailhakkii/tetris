import '../models/game_cell.dart';

abstract class ValidationRule {
  bool isValid(int row, int col, int value, List<List<GameCell>> grid);
}

class RowValidationRule implements ValidationRule {
  @override
  bool isValid(int row, int col, int value, List<List<GameCell>> grid) {
    for (int c = 0; c < 9; c++) {
      if (c != col && grid[row][c].value == value) {
        return false;
      }
    }
    return true;
  }
}

class ColumnValidationRule implements ValidationRule {
  @override
  bool isValid(int row, int col, int value, List<List<GameCell>> grid) {
    for (int r = 0; r < 9; r++) {
      if (r != row && grid[r][col].value == value) {
        return false;
      }
    }
    return true;
  }
}

class BlockValidationRule implements ValidationRule {
  @override
  bool isValid(int row, int col, int value, List<List<GameCell>> grid) {
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (r != row && c != col && grid[r][c].value == value) {
          return false;
        }
      }
    }
    return true;
  }
}

class CompositeValidationRule implements ValidationRule {
  final List<ValidationRule> rules;
  
  CompositeValidationRule(this.rules);
  
  @override
  bool isValid(int row, int col, int value, List<List<GameCell>> grid) {
    for (final rule in rules) {
      if (!rule.isValid(row, col, value, grid)) {
        return false;
      }
    }
    return true;
  }
}