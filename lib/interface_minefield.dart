import 'dart:math';

import 'package:rx_minesweeper/interface_minecell.dart';

enum GameState {
  intro,
  ongoing,
  gameover,
}

abstract class IMineField {
  int get columnCount;
  int get cellCount;
  IBlocMineCell cellAtLinearPosition(int position);
}

abstract class IBlocMineField {
  Sink<void> get resetNewGame;
  Sink<Point<int>> get flagCell;
  Sink<Point<int>> get openCell;

  Stream<GameState> get gameState;
  Stream<IMineField> get field;

  void dispose();
}
