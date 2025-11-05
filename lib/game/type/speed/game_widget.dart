import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soulmath/input/block.dart';
import 'package:soulmath/game/state.dart';
import 'package:soulmath/game/game_widget.dart';
import 'package:soulmath/game/operation/supplier.dart';
import 'package:soulmath/utils/chrono.dart';

class SpeedGameWidget extends GameWidget {
  final int expressionCount = 10;
  SpeedGameWidget(
      super.gameDetails,
      super.operationSupplier,
      super.playerIndex,
      {super.key});

  @override
  State<StatefulWidget> createState() => _SpeedGamePageState();

}

class _SpeedGamePageState extends BaseGameWidgetState<SpeedGameWidget> {
  int _expressionIndex = 0;
  OperationQuestion? _question;
  GameStatus _gameStatus = GameStatus.InProgress;
  Duration _gameDuration = Duration.zero;
  final Chrono _chrono = Chrono();

  @override
  void initState() {
    widget.operationSupplier.prepareQuestions(widget.gameDetails.startTime.millisecondsSinceEpoch,
        widget.expressionCount, widget.gameDetails.playerCount);

    _question = widget.operationSupplier.getPreparedQuestion(widget.gameDetails.key, widget.playerIndex);
    _chrono.start();

    GameStateProvider gameState = Provider.of(context, listen: false);
    gameState.addListener(() {
      GameState playerState = gameState.getState(widget.playerIndex);
      if (playerState.status != _gameStatus) {
        setState(() {
          _gameStatus = playerState.status;
        });
        if (playerState.status == GameStatus.Won) {
          gameState.setDuration(_chrono.stop(), widget.playerIndex);
        }
        else if (playerState.status == GameStatus.Lost) {
          _chrono.stop();
        }
      }
      if (playerState.duration != _gameDuration) {
        setState(() {
          _gameDuration = playerState.duration;
        });
      }
    });
  }
  
  void nextQuestion(BuildContext context) {
    GameStateProvider gameState = Provider.of(context, listen: false);

    _expressionIndex++;

    if (_expressionIndex == widget.expressionCount) {
      gameState.firePlayerWon(widget.playerIndex);
      _question = null;
    } else {
      _question = widget.operationSupplier.getPreparedQuestion(widget.gameDetails.key, widget.playerIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: Center(
                child: _gameStatus == GameStatus.InProgress ?
                Text(
                  _question == null ? "...": _question!.representation,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                ):
                Text(
                  _gameStatus.message,
                  style: TextStyle(fontSize: 28),
                ),
              )
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _gameStatus == GameStatus.InProgress
                    ? SingleNumberInputBlock(
                        onCheckAnswer: (number) {
                          if (_question != null && _question!.verifyAnswer(number)) {
                            setState(() {
                              nextQuestion(context);
                            });
                            return true;
                          }
                          return false;
                        },
                      )
                    : SizedBox(),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$_expressionIndex/${widget.expressionCount}"),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChronoWidget(
              chrono: _chrono,
            ),
          ),
        )
      ],
    );
  }
}

