import 'package:flutter/material.dart';
import 'package:rx_minesweeper/widget_minecell.dart';
import 'interface_minefield.dart';

class GameActivity extends StatefulWidget {
  final IBlocMineField blocMineField;
  GameActivity(this.blocMineField);

  @override
  _GameActivityState createState() => _GameActivityState();
}

class _GameActivityState extends State<GameActivity> {
  @override
  Widget build(BuildContext context) => Scaffold(
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
            StreamBuilder<IMineField>(
                stream: widget.blocMineField.field,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  // final mineFieldDimension = snapshot.data.dimension;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: snapshot.data.columnCount,
                    ),
                    itemBuilder: (context, position) {
                      final blocMineCell =
                          snapshot.data.cellAtLinearPosition(position);
                      return MineCellWidget(blocMineCell);
                    },
                    itemCount: snapshot.data.cellCount,
                  );
                }),
          ],
        ),
      );
}
