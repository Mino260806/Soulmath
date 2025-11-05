import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soulmath/game/details.dart';
import 'package:soulmath/game/type/factory.dart';
import 'package:soulmath/game/page.dart';
import 'package:soulmath/game/operation/profile.dart';
import 'package:soulmath/game/operation/supplier.dart';
import 'package:soulmath/pre_game/game_button.dart';
import 'package:soulmath/pre_game/profile/configure.dart';
import 'package:soulmath/pre_game/transition.dart';

class GameSelectionPage extends StatelessWidget {
  final String title;
  final int playerCount;

  const GameSelectionPage(this.title, {super.key, this.playerCount=1});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 3,
          children: GameType.values
              .where((gameType) => playerCount <= gameType.maxPlayerCount)
              .map((gameType) => GameSelectionButton(gameType, () {
                enterGame(context, gameType);
          })).toList(),
        ),
      ),
    );
  }

  void enterGame(BuildContext context, GameType gameType) {
    configureProfiles(context).then(
            (profiles) => Navigator.push(
            context,
            createGameRoute((context) {
              var supplier = OverallOperationSupplier(profiles);
              GameDetails details = GameDetails(gameType, playerCount, DateTime.now());
              return GamePage(
                  details,
                  gameWidgets: List.generate(playerCount,
                          (index) => GameWidgetFactory.createGameWidget(
                              details, supplier, index)));
            }))
    );
  }

  Future<OperationProfileCollection> configureProfiles(BuildContext context) {
    final result = Completer<OperationProfileCollection>();

    // TODO should be loaded
    var allProfileCollections = OperationProfileCollectionPreset.createAll();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return ProfilesConfigurationSheet(
          allProfileCollections: allProfileCollections,
          selectedIndex: OperationProfileCollectionPreset.Medium.index,
          onStart: (i) {
            result.complete(allProfileCollections[i]);
          },
        );
      },
    );

    return result.future;
  }

}

