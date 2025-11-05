import 'package:flutter/material.dart';
import 'package:soulmath/pre_game/page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Soul Math"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberOfPlayersButton(Icons.person, "Single Player", ((context) => GameSelectionPage("Single Player"))),
            const SizedBox(width: 1, height: 10),
            NumberOfPlayersButton(Icons.people, "Multiplayer Local", ((context) => GameSelectionPage("Multiplayer", playerCount: 2,))),
            const SizedBox(width: 1, height: 10),
            NumberOfPlayersButton(Icons.language, "Multiplayer Online", ((context) => GameSelectionPage("Coming Soon", playerCount: -1,))),
          ],
        ),
      ),
    );
  }

}


class NumberOfPlayersButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final WidgetBuilder pageBuilder;

  const NumberOfPlayersButton(this.iconData, this.text, this.pageBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
            context,
            _createRoute(pageBuilder));
            // MaterialPageRoute(builder: pageBuilder));
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(iconData, size: 24.0),
            const SizedBox(width: 10, height: 0),
            Text(text)
          ],
        ),
      ),
    );
  }

}

Route _createRoute(WidgetBuilder pageBuilder) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pageBuilder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
