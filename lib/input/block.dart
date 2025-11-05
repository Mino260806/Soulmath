import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soulmath/input/field.dart';
import 'package:soulmath/input/keyboard.dart';

class SingleNumberInputBlock extends StatefulWidget {
  final bool Function(int)? onCheckAnswer;
  final bool enabled;

  const SingleNumberInputBlock({super.key, this.onCheckAnswer, this.enabled = true});

  @override
  State<SingleNumberInputBlock> createState() => _SingleNumberInputBlockState();
}

class _SingleNumberInputBlockState extends State<SingleNumberInputBlock> {
  final NumberInputNotifier _inputNotifier = NumberInputNotifier();
  final NumberEditingController _numberFieldController = NumberEditingController();

  @override
  void initState() {
    _inputNotifier.addListener(() {
      if (_inputNotifier.value != "") {
        _numberFieldController.inputChar(_inputNotifier.value);
      }
      _inputNotifier.value = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberField(
          controller: _numberFieldController,
          onCheckAnswer: widget.onCheckAnswer,
        ),
        SizedBox(height: 10.0),
        Expanded(
          child: Keyboard(
            enabled: widget.enabled,
            inputNotifier: _inputNotifier,
          ),
        ),
      ],
    );
  }
}
