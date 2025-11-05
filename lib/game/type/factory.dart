import 'package:flutter/material.dart';
import 'package:soulmath/game/details.dart';
import 'package:soulmath/game/game_widget.dart';
import 'package:soulmath/game/operation/supplier.dart';
import 'package:soulmath/game/type/infinite/game_widget.dart';
import 'package:soulmath/game/type/speed/game_widget.dart';

enum GameType {
  Speed("Speed Mode", Icons.speed_rounded, 2),
  Infinite("Infinite Mode", Icons.all_inclusive,  1),
  ;

  final String title;
  final IconData icon;

  final int maxPlayerCount;
  const GameType(this.title, this.icon, this.maxPlayerCount);
}

class GameWidgetFactory {
  static GameWidget createGameWidget(
      GameDetails details,
      OverallOperationSupplier supplier,
      int playerIndex,
    ) {
    switch (details.type) {
      case GameType.Speed:
        return SpeedGameWidget(details, supplier, playerIndex);
      case GameType.Infinite:
        return InfiniteGameWidget(details, supplier, playerIndex);
      default:
        throw new UnsupportedError("Not implemented yet");
    }
  }
}
