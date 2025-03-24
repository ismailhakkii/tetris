import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CellState {
  empty,
  filled,
  invalid,
  valid,
  fixed,
}

class GameCell extends Equatable {
  final int row;
  final int col;
  final int? value;
  final CellState state;
  
  const GameCell({
    required this.row,
    required this.col,
    this.value,
    this.state = CellState.empty,
  });
  
  GameCell copyWith({
    int? row,
    int? col,
    int? value,
    CellState? state,
  }) {
    return GameCell(
      row: row ?? this.row,
      col: col ?? this.col,
      value: value ?? this.value,
      state: state ?? this.state,
    );
  }
  
  Color get backgroundColor {
    switch (state) {
      case CellState.empty:
        return Colors.white;
      case CellState.filled:
        return Colors.white;
      case CellState.invalid:
        return Colors.red[200]!;
      case CellState.valid:
        return Colors.green.withOpacity(0.3);
      case CellState.fixed:
        return Colors.grey[350]!;
    }
  }
  
  bool get isFixed => state == CellState.fixed;
  bool get isEmpty => value == null;
  
  @override
  List<Object?> get props => [row, col, value, state];
}