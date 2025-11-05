import 'package:flutter/material.dart';
import 'package:soulmath/input/block.dart';
import 'package:soulmath/game/game_widget.dart';
import 'package:soulmath/game/operation/supplier.dart';

class InfiniteGameWidget extends GameWidget {
  const InfiniteGameWidget(
      super.gameDetails,
      super.operationSupplier,
      super.playerIndex,
      {super.key});

  @override
  State<StatefulWidget> createState() => _InfiniteGamePageState();

}

class _InfiniteGamePageState extends BaseGameWidgetState<InfiniteGameWidget> {
  int _expressionIndex = 0;
  OperationQuestion? _question;

  @override
  void initState() {
    _question = widget.operationSupplier.getQuestion();
  }
  
  void nextQuestion() {
    _question = widget.operationSupplier.getQuestion();
    _expressionIndex++;
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
                child: Text(
                  _question == null ? "...": _question!.representation,
                  textScaleFactor: 2.5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleNumberInputBlock(
                onCheckAnswer: (number) {
                  if (_question != null && _question!.verifyAnswer(number)) {
                    setState(() {
                      nextQuestion();
                    });
                    return true;
                  }
                  return false;
                },
              )
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$_expressionIndex"),
          ),
        ),
      ],
    );
  }
}