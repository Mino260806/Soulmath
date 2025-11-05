import 'package:flutter/material.dart';
import 'package:soulmath/game/type/factory.dart';

class GameSelectionButton extends StatelessWidget {
  final GameType gameType;
  final VoidCallback? onPressed;

  const GameSelectionButton(this.gameType, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(gameType.icon, size: 48.0),
              Text(gameType.title, textAlign: TextAlign.center)
            ],
          )
      ),
    );
  }

}