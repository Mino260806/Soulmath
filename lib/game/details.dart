import 'package:soulmath/game/type/factory.dart';

class GameDetails {
  final GameType type;
  final int playerCount;
  final DateTime startTime;

  int get key => startTime.millisecondsSinceEpoch;

  GameDetails(this.type, this.playerCount, this.startTime);
}
