import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart' show BehaviorSubject;

abstract class IBlocMineCell {
  Sink<IBlocMineCell> get neighbor;
  Sink<MineCellInteraction> get interact;

  Stream<bool> get isBomb;
  Stream<MineCellPresentation> get cellPresentation;
  void dispose();
}

enum MineCellInteraction {
  nextFlag,
  reveal,
}

enum MineCellPresentation {
  n0,
  n1,
  n2,
  n3,
  n4,
  n5,
  n6,
  n7,
  n8,
  bomb,
  flagged,
  uncertain,
  unrevealed,
}

class BlocMineCell implements IBlocMineCell {
  final neighborSubject = BehaviorSubject<IBlocMineCell>();
  get neighbor => neighborSubject.sink;
  final interactSubject = BehaviorSubject<MineCellInteraction>();
  get interact => interactSubject;

  final isBombSubject = BehaviorSubject<bool>.seeded(false);
  get isBomb => isBombSubject.stream;
  final isCovered = BehaviorSubject<bool>.seeded(true);
  final state = BehaviorSubject<MineCellPresentation>.seeded(
      MineCellPresentation.unrevealed);
  final BehaviorSubject<MineCellPresentation> cellPresentationBahaviour;
  get cellPresentation => cellPresentationBahaviour.distinct();

  BlocMineCell({initCellPresentation: MineCellPresentation.unrevealed})
      : cellPresentationBahaviour =
            BehaviorSubject<MineCellPresentation>.seeded(initCellPresentation) {
    // @todo short circut if this cell is a bomb
    final neighborBombStream = neighborSubject
        .flatMap((cell) => cell.isBomb)
        .map((isBomb) => isBomb ? 1 : 0)
        .scan<int>(
          (accumulated, currentValue, _) => accumulated += currentValue,
          0,
        )
        .distinct()
        .shareValueSeeded(0);

    interactSubject.stream
        .withLatestFrom3<int, MineCellPresentation, bool, MineCellPresentation>(
            neighborBombStream, cellPresentation, isBomb,
            (thisInteraction, latestNeighborBomb, latestPresentation, isBomb) {
          // return MineCellPresentation.flagged;
          switch (thisInteraction) {
            case MineCellInteraction.nextFlag:
              switch (latestPresentation) {
                case MineCellPresentation.n0:
                case MineCellPresentation.n1:
                case MineCellPresentation.n2:
                case MineCellPresentation.n3:
                case MineCellPresentation.n4:
                case MineCellPresentation.n5:
                case MineCellPresentation.n6:
                case MineCellPresentation.n7:
                case MineCellPresentation.n8:
                case MineCellPresentation.bomb:
                  return latestPresentation;

                case MineCellPresentation.unrevealed:
                  return MineCellPresentation.flagged;

                case MineCellPresentation.flagged:
                  return MineCellPresentation.uncertain;

                case MineCellPresentation.uncertain:
                  return MineCellPresentation.unrevealed;
              }
              // todo should not reach this
              return latestPresentation;
            case MineCellInteraction.reveal:
              switch (latestPresentation) {
                case MineCellPresentation.n0:
                case MineCellPresentation.n1:
                case MineCellPresentation.n2:
                case MineCellPresentation.n3:
                case MineCellPresentation.n4:
                case MineCellPresentation.n5:
                case MineCellPresentation.n6:
                case MineCellPresentation.n7:
                case MineCellPresentation.n8:
                case MineCellPresentation.bomb:
                case MineCellPresentation.flagged:
                case MineCellPresentation.uncertain:
                  return latestPresentation;
                case MineCellPresentation.unrevealed:
                  if (isBomb) {
                    return MineCellPresentation.bomb;
                  }
                  return MineCellPresentation.values[latestNeighborBomb];
              }
          }
          // todo should not reach this
          return latestPresentation;
        })
        .distinct()
        .pipe(cellPresentationBahaviour);
  }

  @override
  void dispose() async {
    isBombSubject.close();
    isCovered.close();
    state.close();
    neighborSubject.close();
    interactSubject.close();
    cellPresentationBahaviour.close();
  }
}
