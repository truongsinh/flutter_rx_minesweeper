import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:rx_minesweeper/bloc_minecell.dart'
    show BlocMineCell, IBlocMineCell, MineCellInteraction, MineCellPresentation;

void main() {
  IBlocMineCell blocMineCell;
  setUp(() {
    blocMineCell = BlocMineCell();
  });
  tearDown(() {
    // blocMineCell.dispose();
  });
  test('blockMineCell isBomb', () async {
    (blocMineCell as BlocMineCell).isBombSubject.add(true);
    blocMineCell.interact.add(MineCellInteraction.reveal);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.unrevealed,
        MineCellPresentation.bomb,
        emitsDone
      ]),
    );
  });
  test('blockMineCell add static bomb neighbor', () async {
    final neighborWithBomb = BlocMineCell()..isBombSubject.add(true);
    final neighborWithoutBomb = BlocMineCell()..isBombSubject.add(false);
    blocMineCell.neighbor.add(neighborWithBomb);
    blocMineCell.neighbor.add(neighborWithoutBomb);
    blocMineCell.neighbor.add(neighborWithBomb);
    blocMineCell.neighbor.add(neighborWithoutBomb);
    // @todo it's better if we don't have to wait, event 1 microsecond;
    await Future.delayed(Duration(microseconds: 1));
    blocMineCell.interact.add(MineCellInteraction.reveal);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.unrevealed,
        MineCellPresentation.n2,
        emitsDone,
      ]),
    );
  });
  test('blockMineCell add dynamic bomb neighbor', () async {
    final neighborWithBomb = BlocMineCell()..isBombSubject.add(true);
    final neighborWithBombAddedLater = BlocMineCell()..isBombSubject.add(false);
    blocMineCell.neighbor.add(neighborWithBomb);
    blocMineCell.neighbor.add(neighborWithBombAddedLater);
    blocMineCell.neighbor.add(neighborWithBomb);
    blocMineCell.neighbor.add(neighborWithBombAddedLater);
    neighborWithBombAddedLater.isBombSubject.add(true);

    // @todo it's better if we don't have to wait, event 1 microsecond;
    await Future.delayed(Duration(microseconds: 1));
    blocMineCell.interact.add(MineCellInteraction.reveal);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.unrevealed,
        MineCellPresentation.n4,
        emitsDone,
      ]),
    );
  });

  test('blockMineCell next flag flagged', () async {
    blocMineCell.interact.add(MineCellInteraction.nextFlag);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.unrevealed,
        MineCellPresentation.flagged,
        emitsDone,
      ]),
    );
  });
  test('blockMineCell next flag uncertain', () async {
    blocMineCell =
        BlocMineCell(initCellPresentation: MineCellPresentation.flagged);
    blocMineCell.interact.add(MineCellInteraction.nextFlag);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.flagged,
        MineCellPresentation.uncertain,
        emitsDone,
      ]),
    );
  });
  test('blockMineCell next flag unrevealed', () async {
    blocMineCell =
        BlocMineCell(initCellPresentation: MineCellPresentation.uncertain);
    blocMineCell.interact.add(MineCellInteraction.nextFlag);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.uncertain,
        MineCellPresentation.unrevealed,
        emitsDone,
      ]),
    );
  });
  test('blockMineCell flagged cannot be revealed', () async {
    blocMineCell =
        BlocMineCell(initCellPresentation: MineCellPresentation.flagged);
    blocMineCell.interact.add(MineCellInteraction.reveal);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.flagged,
        emitsDone,
      ]),
    );
  });
  test('blockMineCell uncertain cannot be revealed', () async {
    blocMineCell =
        BlocMineCell(initCellPresentation: MineCellPresentation.uncertain);
    blocMineCell.interact.add(MineCellInteraction.reveal);
    blocMineCell.interact.close();
    expect(
      blocMineCell.cellPresentation,
      emitsInOrder([
        MineCellPresentation.uncertain,
        emitsDone,
      ]),
    );
  });
}
