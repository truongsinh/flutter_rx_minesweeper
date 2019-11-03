import 'dart:math';

import 'package:rxdart/subjects.dart';

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
  final Random randomGen;
  final List<List<IBlocMineCell>> fieldRows;
  MineField(this.dimension, totalBomb, {int randomSeed})
      : randomGen = Random(randomSeed),
        fieldRows = List<List<IBlocMineCell>>(dimension.y) {
    assert(dimension.y > 0);
    assert(dimension.x > 0);
    assert(totalBomb >= 0);

    int remainingCell = dimension.x * dimension.y;
    int remaininBomb = totalBomb;

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

  void reset(int totalBomb) {
    int remainingCell = dimension.x * dimension.y;
    /*
    int remaininBomb = totalBomb;
    for (var thisRow = 0; thisRow < dimension.y; thisRow++) {
      for (var thisColumn = 0; thisColumn < dimension.x; thisColumn++) {
        final mineCell = fieldRows[thisRow][thisColumn] as BlocMineCell;
        mineCell.resetPresentation.add(MineCellPresentation.unrevealed);
        if (shouldThisCellRandomlyIsBomb(
            remaininBomb, remainingCell, randomGen)) {
          mineCell.isBombSubject.add(true);
          remaininBomb--;
        } else {
          mineCell.isBombSubject.add(false);
        }
        remainingCell--;
      }
    }
    */
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
      if (thisColumn < dimension.x - 1) {
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

abstract class IBlocMineField {
  Sink<void> get resetNewGame;
  Sink<Point<int>> get flagCell;
  Sink<Point<int>> get openCell;

  Stream<GameState> get gameState;
  Stream<MineField> get field;

  void dispose();
}

class BlocMineField implements IBlocMineField {
  final BehaviorSubject<void> resetNewGame = BehaviorSubject<void>.seeded(null);
  final BehaviorSubject<GameState> gameState =
      BehaviorSubject.seeded(GameState.intro);
  final BehaviorSubject<Point<int>> flagCell = BehaviorSubject<Point<int>>();
  final BehaviorSubject<Point<int>> openCell = BehaviorSubject<Point<int>>();

  final BehaviorSubject<MineField> field;

  BlocMineField([randomSeed])
      : field = BehaviorSubject<MineField>.seeded(
            MineField(Point(10, 8), 10, randomSeed: randomSeed)) {
    resetNewGame.map((_) => GameState.intro).pipe(gameState.sink);
    resetNewGame.withLatestFrom<MineField, MineField>(field, (_, mineField) {
      mineField.dispose();
      return MineField(Point(15, 15), 10);
      /*
      // @todo not yet FRP
      mineField.reset(10);
      return mineField;
      */
    }).pipe(field);

    flagCell
        .withLatestFrom<MineField, IBlocMineCell>(
            field,
            (pointToFlag, field) =>
                field.fieldRows[pointToFlag.y][pointToFlag.x])
        // @todo not yet FRP
        .listen((cell) => cell.interact.add(MineCellInteraction.nextFlag));

    openCell
        .withLatestFrom<MineField, IBlocMineCell>(
            field,
            (pointToFlag, field) =>
                field.fieldRows[pointToFlag.y][pointToFlag.x])
        // @todo not yet FRP
        .listen((cell) => cell.interact.add(MineCellInteraction.reveal));
  }

  @override
  void dispose() {
    resetNewGame.close();
    gameState.close();
    field.close();
    flagCell.close();
  }
}
