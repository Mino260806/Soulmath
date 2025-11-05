import 'package:flutter/cupertino.dart';
import 'package:soulmath/game/details.dart';
import 'package:soulmath/game/operation/supplier.dart';

abstract class GameWidget extends StatefulWidget {
  final GameDetails gameDetails;
  final OverallOperationSupplier operationSupplier;
  final int playerIndex;

  const GameWidget(
      this.gameDetails,
      this.operationSupplier,
      this.playerIndex,
      {super.key});

}

abstract class BaseGameWidgetState<T extends GameWidget> extends State<T> {
}
