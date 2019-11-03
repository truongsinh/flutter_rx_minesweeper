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
