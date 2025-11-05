import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soulmath/game/details.dart';
import 'package:soulmath/game/state.dart';
import 'package:soulmath/game/game_widget.dart';

class GamePage extends StatefulWidget {
  final GameDetails gameDetails;
  final List<GameWidget> gameWidgets;

  GamePage(this.gameDetails, {
    super.key,
    required this.gameWidgets,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => KeyboardInputProvider()),
        ChangeNotifierProvider(create: (c) => GameStateProvider(widget.gameDetails.playerCount)),
      ],
    builder: (context, child) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              GameStateProvider gameDetailsProvider = Provider.of(context, listen: false);
              if (gameDetailsProvider.getState(0).status == GameStatus.InProgress) {
                showDialog(
                    context: context,
                    builder: ((alertContext) => AlertDialog(
                      title: const Text("Are you sure ?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(alertContext).pop(),
                            child: const Text("No")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(alertContext).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Yes")),
                      ],
                    )));
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(widget.gameDetails.type.title),
        ),
        body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            if (widget.gameDetails.playerCount == 1) {
              if (event is RawKeyDownEvent) {
                Provider
                    .of<KeyboardInputProvider>(context, listen: false)
                    .value = event!;
              }
            }
          },
          child: widget.gameDetails.playerCount == 1
              ? widget.gameWidgets[0]
              : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: Transform.rotate(
                          angle: pi,
                          child: widget.gameWidgets[0]
                      ),
                  ),
                  Divider(),
                  Expanded(child: widget.gameWidgets[1]),
                ],
          ),
        ),
      );
    });
  }
}

class KeyboardInputProvider extends ValueNotifier<RawKeyEvent?> {
  KeyboardInputProvider(): super(null);

}
