import 'package:flutter/material.dart';
import 'bloc_minecell.dart';
import 'bloc_minefield.dart';

// Types of images available
enum ImageType {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
  facingDown,
  flagged,
}

class GameActivity extends StatefulWidget {
  final IBlocMineField blocMineField;
  GameActivity(this.blocMineField);

  @override
  _GameActivityState createState() => _GameActivityState();
}

class _GameActivityState extends State<GameActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.grey,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () => widget.blocMineField.resetNewGame.add(null),
                  child: CircleAvatar(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    backgroundColor: Colors.yellowAccent,
                  ),
                )
              ],
            ),
          ),
          // The grid of squares
          StreamBuilder<MineField>(
              stream: widget.blocMineField.field,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                final mineFieldDimension = snapshot.data.dimension;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: mineFieldDimension.x,
                  ),
                  itemBuilder: (context, position) {
                    final columnCount = snapshot.data.dimension.x;
                    // Get row and column number of square
                    final int rowNumber = (position / columnCount).floor();
                    final int columnNumber = (position % columnCount);
                    final blocMineCell =
                        snapshot.data.fieldRows[rowNumber][columnNumber];
                    return MineCellWidget(blocMineCell);
                  },
                  itemCount: mineFieldDimension.x * mineFieldDimension.y,
                );
              }),
        ],
      ),
    );
  }

  // Function to handle when a bomb is clicked.
  void _handleGameOver() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over!"),
          content: Text("You stepped on a mine!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                widget.blocMineField.resetNewGame.add(null);
                Navigator.pop(context);
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You Win!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                widget.blocMineField.resetNewGame.add(null);
                Navigator.pop(context);
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }
}

class MineCellWidget extends StatelessWidget {
  final IBlocMineCell blocCell;
  MineCellWidget(this.blocCell);

  @override
  Widget build(BuildContext context) => StreamBuilder<MineCellPresentation>(
      stream: blocCell.cellPresentation,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        Image image;

        final p = snapshot.data;

        if (p == MineCellPresentation.flagged) {
          image = getImage(ImageType.flagged);
        } else if (p == MineCellPresentation.uncertain) {
          image = getImage(ImageType.facingDown);
        } else if (p == MineCellPresentation.unrevealed) {
          image = getImage(ImageType.facingDown);
        } else if (p == MineCellPresentation.bomb) {
          image = getImage(ImageType.bomb);
        } else {
          image = getImage(getImageTypeFromNumber(p.index));
        }

        return InkWell(
          onTap: () => blocCell.interact.add(MineCellInteraction.reveal),
          onLongPress: () =>
              blocCell.interact.add(MineCellInteraction.nextFlag),
          splashColor: Colors.grey,
          child: Container(
            color: Colors.grey,
            child: image,
          ),
        );
      });
}

Image getImage(ImageType type) {
  switch (type) {
    case ImageType.zero:
      return Image.asset('images/0.png');
    case ImageType.one:
      return Image.asset('images/1.png');
    case ImageType.two:
      return Image.asset('images/2.png');
    case ImageType.three:
      return Image.asset('images/3.png');
    case ImageType.four:
      return Image.asset('images/4.png');
    case ImageType.five:
      return Image.asset('images/5.png');
    case ImageType.six:
      return Image.asset('images/6.png');
    case ImageType.seven:
      return Image.asset('images/7.png');
    case ImageType.eight:
      return Image.asset('images/8.png');
    case ImageType.bomb:
      return Image.asset('images/bomb.png');
    case ImageType.facingDown:
      return Image.asset('images/facingDown.png');
    case ImageType.flagged:
      return Image.asset('images/flagged.png');
    default:
      return null;
  }
}

ImageType getImageTypeFromNumber(int number) {
  switch (number) {
    case 0:
      return ImageType.zero;
    case 1:
      return ImageType.one;
    case 2:
      return ImageType.two;
    case 3:
      return ImageType.three;
    case 4:
      return ImageType.four;
    case 5:
      return ImageType.five;
    case 6:
      return ImageType.six;
    case 7:
      return ImageType.seven;
    case 8:
      return ImageType.eight;
    default:
      return null;
  }
}
