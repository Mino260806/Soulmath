import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soulmath/game/page.dart';

class Keyboard extends StatefulWidget {
  final NumberInputNotifier? inputNotifier;
  final bool enabled;

  const Keyboard({super.key, this.inputNotifier, this.enabled=true});

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  @override
  void initState() {
    var keyboardInputProvider = Provider.of<KeyboardInputProvider>(context, listen: false);
    keyboardInputProvider.addListener(() {
      RawKeyEvent? keyEvent = keyboardInputProvider.value;
      if (keyEvent != null) {
        if (keyEvent.character != null
            && keyEvent.character!.codeUnitAt(0) >= 48
            && keyEvent.character!.codeUnitAt(0) <= 57) {
          widget.inputNotifier?.value = keyEvent!.character!;
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
          widget.inputNotifier?.value = "x";
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowLeft) {
          widget.inputNotifier?.value = "<";
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowRight) {
          widget.inputNotifier?.value = ">";
        } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
          widget.inputNotifier?.value = "e";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: constraints.maxHeight > constraints.maxWidth?
              constraints.maxWidth: constraints.maxHeight,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KeyboardButton(char: "1", inputNotifier: widget.inputNotifier, enabled: widget.enabled,),
                      _KeyboardButton(char: "4", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "7", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "<", icon: Icons.chevron_left_rounded, inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KeyboardButton(char: "2", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "5", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "8", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "0", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KeyboardButton(char: "3", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "6", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: "9", inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                      _KeyboardButton(char: ">", icon: Icons.chevron_right_rounded,
                          inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _KeyboardButton(char: "x", icon: Icons.backspace_outlined,
                          inputNotifier: widget.inputNotifier, enabled: widget.enabled),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  final String char;
  final IconData? icon;
  final NumberInputNotifier? inputNotifier;
  final bool enabled;

  const _KeyboardButton({super.key,
    required this.char,
    this.icon,
    this.inputNotifier,
    this.enabled=true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: OutlinedButton(
          onPressed: enabled ? () {
            inputNotifier?.value = char;
          }: null,
          onLongPress: enabled ? () {
            inputNotifier?.value = char.toUpperCase();
          } : null,
          child: icon != null? Icon(icon!): Text(char!),
        ),
      ),
    );
  }
}

class NumberInputNotifier extends ValueNotifier<String> {
  NumberInputNotifier() : super("");

}
