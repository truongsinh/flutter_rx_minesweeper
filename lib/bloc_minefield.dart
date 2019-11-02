import 'dart:math';

import 'bloc_minecell.dart';

// @todo not guaranteed to be cryptographically secured
// @todo any chance 2 remaining bomb, 1 remaining cell?
bool shouldThisCellRandomlyIsBomb(
  int totalRemainingBomb,
  int totalRemainingCellInclusive,
  Random randomGen,
) {
  assert(totalRemainingBomb >= 0);
  assert(totalRemainingCellInclusive >= 1);
  if (totalRemainingBomb == 0) {
    return false;
  }
  if (totalRemainingCellInclusive == 1) {
    return true;
  }
  final randomValue = randomGen.nextDouble();
  return randomValue < totalRemainingBomb / totalRemainingCellInclusive;
}

class MineField {
  final Point<int> dimension;
  final int totalBomb;
  final int randomSeed;
  Random randomGen;
  List<List<IBlocMineCell>> fieldRows;
  MineField(this.dimension, this.totalBomb, {this.randomSeed}) {
    // @todo hardcode game param for now
    assert(dimension == Point(10, 8));
    assert(totalBomb == 10);
    fieldRows = List<List<IBlocMineCell>>(dimension.y);

    int remainingCell = dimension.x * dimension.y;
    int remaininBomb = totalBomb;

    if (this.randomSeed != null) {
      randomGen = Random(this.randomSeed);
    } else {
      randomGen = Random();
    }

    for (var thisRow = 0; thisRow < dimension.y; thisRow++) {
      final fieldCellsInARow = List<IBlocMineCell>(dimension.x);
      fieldRows[thisRow] = fieldCellsInARow;
      for (var thisColumn = 0; thisColumn < dimension.x; thisColumn++) {
        final mineCell = BlocMineCell();
        if (shouldThisCellRandomlyIsBomb(
            remaininBomb, remainingCell, randomGen)) {
          mineCell.isBombSubject.add(true);
          remaininBomb--;
        }
        remainingCell--;
        fieldCellsInARow[thisColumn] = mineCell;

        _connectThisCellToItsNeighbor(thisRow, thisColumn, mineCell);
      }
    }
  }

  void _connectThisCellToItsNeighbor(thisRow, thisColumn, mineCell) {
    if (thisColumn > 0) {
      final itsMidLeft = fieldRows[thisRow][thisColumn - 1];
      itsMidLeft.neighbor.add(mineCell);
      mineCell.neighbor.add(itsMidLeft);
    }
    if (thisRow > 0) {
      if (thisColumn > 0) {
        final itsTopLeft = fieldRows[thisRow - 1][thisColumn - 1];
        itsTopLeft.neighbor.add(mineCell);
        mineCell.neighbor.add(itsTopLeft);
      }
      {
        final itsTopCenter = fieldRows[thisRow - 1][thisColumn];
        itsTopCenter.neighbor.add(mineCell);
        mineCell.neighbor.add(itsTopCenter);
      }
      if (thisColumn < dimension.y) {
        final itsTopRight = fieldRows[thisRow - 1][thisColumn + 1];
        itsTopRight.neighbor.add(mineCell);
        mineCell.neighbor.add(itsTopRight);
      }
    }
  }

  dispose() {
    for (var i = 0; i < dimension.y; i++) {
      for (var j = 0; j < dimension.x; j++) {
        fieldRows[i][j].dispose();
      }
    }
  }
}

enum GameState {
  intro,
  ongoing,
  gameover,
}

// abstract class IBlocMineField {
//   Sink<MineField> get resetNewGame;
//   Sink<Point<int>> get flagCell;
//   Sink<Point<int>> get openCell;

//   Stream<GameState> get gameState;
//   Stream<List<List<Stream<IBlocMineCell>>>> field;

//   void dispose();
// }

// class BlocMineField implements IBlocMineField {
//   final resetNewGameSubject =
//       BehaviorSubject.seeded(MineField(Point(10, 8), 10));
//   final gameStateSubject = BehaviorSubject.seeded(GameState.intro);

//   BlocMineField() {
//     resetNewGameSubject.map((_) => GameState.ongoing).pipe(gameStateSubject.sink);
//     resetNewGameSubject.map((minefieldSetting) {
//       // @todo dispose previous field
//       List<List<IBlocMineCell>> field;

//     })
//   }

//   @override
//   List<List<Stream<IBlocMineCell>>> field;

//   @override
//   // TODO: implement flagCell
//   Sink<Point<int>> get flagCell => null;

//   @override
//   // TODO: implement gameState
//   Stream<GameState> get gameState => null;

//   @override
//   // TODO: implement openCell
//   Sink<Point<int>> get openCell => null;

//   @override
//   // TODO: implement resetNewGame
//   Sink<MineField> get resetNewGame => resetNewGameSubject.sink;

//   @override
//   void dispose() {
//     resetNewGameSubject.close();
//     gameStateSubject.close();
//   }
// }
