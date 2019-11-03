import 'package:flutter/material.dart';

import 'interface_minecell.dart';

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

        Widget image;

        final p = snapshot.data;

        if (p.index <= MineCellPresentation.bomb.index) {
          Text text;
          if (p.index > MineCellPresentation.n0.index) {
            if (p.index < MineCellPresentation.bomb.index) {
              const numberColor = [
                0xFF1e00FF,
                0xFF007B00,
                0xFFFF0000,
                0xFF0E007C,
                0xFF890000,
                0xFF007979,
                0xFF8A007B,
                0xFF6A6A6A,
              ];
              text = Text(
                '${p.index}',
                style: TextStyle(
                    color: Color(numberColor[p.index - 1]),
                    fontWeight: FontWeight.w900),
              );
            } else {
              text = Text('💣');
            }
          } else {
            text = Text('');
          }
          image = Container(
            child: FittedBox(fit: BoxFit.contain, child: text),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500, width: 2),
            ),
          );
        } else {
          String marker = '';
          if (p == MineCellPresentation.flagged) {
            marker = '🚩';
          } else if (p == MineCellPresentation.uncertain) {
            marker = '🤔';
          }
          image = Stack(fit: StackFit.expand, children: [
            Image.asset('images/raised-cell.png'),
            Container(
                padding: EdgeInsets.only(bottom: 5),
                child: FittedBox(fit: BoxFit.contain, child: Text(marker))),
          ]);
        }

        return InkWell(
          onTap: () => blocCell.interact.add(MineCellInteraction.reveal),
          onLongPress: () =>
              blocCell.interact.add(MineCellInteraction.nextFlag),
          splashColor: Colors.grey,
          child: Container(
            color: Colors.grey.shade400,
            child: image,
          ),
        );
      });
}
