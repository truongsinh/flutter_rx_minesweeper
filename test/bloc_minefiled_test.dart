import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rx_minesweeper/bloc_minecell.dart';

import 'package:rx_minesweeper/bloc_minefield.dart'
    show MineField, shouldThisCellRandomlyIsBomb;

void main() {
  Random random;
  setUp(() {
    random = Random(42);
  });
  group('shouldThisCellRandomlyIsBomb', () {
    test('0 bomb 0 cell throws assertion error', () async {
      expect(() => shouldThisCellRandomlyIsBomb(0, 0, random),
          throwsAssertionError);
    });
    test('1 bomb 0 cell throws assertion error', () async {
      expect(() => shouldThisCellRandomlyIsBomb(1, 0, random),
          throwsAssertionError);
    });
    test('0 bomb 1 cell returns false', () async {
      expect(shouldThisCellRandomlyIsBomb(0, 1, random), false);
    });
    test('1 bomb 1 cell returns true', () async {
      expect(shouldThisCellRandomlyIsBomb(1, 1, random), true);
    });
    test('100 bombs 100 cells returns true', () async {
      expect(shouldThisCellRandomlyIsBomb(100, 100, random), true);
    });
    test(
        '25 bombs 100 cells returns 25% probability with controlled randomness',
        () async {
      final listOfGeneratedBomb = List<bool>.generate(
          100, (_) => shouldThisCellRandomlyIsBomb(25, 100, random),
          growable: false);
      expect(listOfGeneratedBomb.where((e) => e).toList(), hasLength(24));
    });
    test('place enough number of bombs with uncontrolled randomness', () async {
      final bombNeeded = 31;
      final totalCell = 100;

      var totalRemainingBombs = bombNeeded;

      final cellList = List<bool>.generate(totalCell, (cellIndex) {
        final totalRemainingCells = totalCell - cellIndex;
        final isBomb = shouldThisCellRandomlyIsBomb(
            totalRemainingBombs, totalRemainingCells, Random());
        if (isBomb) {
          totalRemainingBombs--;
        }
        return isBomb;
      }, growable: false);
      expect(cellList.where((e) => e).toList(), hasLength(31));
    });
  });

  // @todo field should show number of bombs in the neighbor
  group('MineField with seed 42', () {
    final numOfColumn = 10;
    final numOfRow = 8;
    final field = MineField(Point(numOfColumn, numOfRow), 10, randomSeed: 42);

    // 9 is bomb
    final expectedRevealedMinedField = [
      /* column    0  1  2  3  4  5  6  7  8  9       */
      /* row 0 */ [0, 0, 1, 1, 1, 0, 0, 0, 0, 0] /* 0 */,
      /* row 1 */ [0, 0, 1, 9, 1, 0, 1, 2, 2, 0] /* 1 */,
      /* row 2 */ [0, 0, 1, 1, 1, 0, 1, 9, 9, 1] /* 2 */,
      /* row 3 */ [0, 1, 1, 1, 0, 0, 1, 2, 3, 2] /* 3 */,
      /* row 4 */ [1, 2, 9, 1, 0, 1, 1, 1, 1, 9] /* 4 */,
      /* row 5 */ [2, 9, 2, 1, 0, 1, 9, 1, 0, 1] /* 5 */,
      /* row 6 */ [9, 3, 2, 0, 0, 1, 1, 2, 1, 0] /* 6 */,
      /* row 7 */ [2, 9, 1, 0, 0, 0, 0, 1, 9, 1] /* 7 */,
      /* column    0  1  2  3  4  5  6  7  8  9       */
    ];
    test('has correct # of rows and columns', () {
      final fieldRows = field.fieldRows;
      expect(fieldRows, hasLength(8));
      final fieldCellsInARow = fieldRows[0];
      expect(fieldCellsInARow, hasLength(10));
    });
    List.generate(numOfRow, (thisRow) {
      List.generate(numOfColumn, (thisColumn) {
        final expectedFaceValue =
            expectedRevealedMinedField[thisRow][thisColumn];
        test(
            'row $thisRow, column $thisColumn has faceValue $expectedFaceValue',
            () {
          final fieldRows = field.fieldRows;
          fieldRows[thisRow][thisColumn].interact
            ..add(MineCellInteraction.reveal)
            ..close();
          expect(
            fieldRows[thisRow][thisColumn].cellPresentation,
            emitsInOrder([
              MineCellPresentation.unrevealed,
              MineCellPresentation.values[expectedFaceValue],
              emitsDone,
            ]),
          );
        });
      });
    });
  });
}
