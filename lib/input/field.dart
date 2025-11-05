import 'package:flutter/material.dart';

class NumberField extends StatefulWidget {
  final NumberEditingController? controller;
  final bool Function(int)? onCheckAnswer;
  const NumberField({super.key, this.controller, this.onCheckAnswer});

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  String _text = "";
  int _cursorPosition = 0;
  double _cursorOffset = 0;

  static const TextStyle textStyle = TextStyle(fontSize: 20);

  @override
  void initState() {
    _text = widget.controller?.text ?? "";
    _cursorPosition = 0;
    _cursorOffset = 0;

    widget.controller?.addListener(() {
      String newText = widget.controller?.text ?? "";
      int newPosition = widget.controller?.selection.baseOffset ?? 0;
      bool validate = widget.controller?.validate ?? false;

      if (validate) {
        validateAnswer();
        return;
      }

      setState(() {
        _text = newText;
        _cursorPosition = newPosition;
        if (_cursorPosition < 0) _cursorPosition = newText.length;

        _cursorOffset = calculateCursorOffset(_text, _cursorPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(_text, style: textStyle),
                  Positioned(
                    top: 0,
                    left: _cursorOffset,
                    child: Container(
                      width: 2,
                      height: textStyle.fontSize! + 8,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                validateAnswer();
              },
              icon: const Icon(Icons.done_rounded),
              color: Theme.of(context).colorScheme.primary,
              // padding: EdgeInsets.zero,
              // constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  double calculateCursorOffset(String text, int cursorPosition) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.substring(0, cursorPosition),
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    return textPainter.width;
  }

  void validateAnswer() {
    int? number = int.tryParse(_text);
    if (number != null && widget.onCheckAnswer != null) {
      if (widget.onCheckAnswer!(number)) {
        widget.controller?.clear();
      }
    }
  }
}

class NumberEditingController extends ValueNotifier<NumberEditingValue> {
  NumberEditingController(): super(NumberEditingValue()) {
    selection = const TextSelection.collapsed(offset: 0);
  }

  String get text => value.text;
  set text(newText) {
    value = value.copyWith(text: newText);
  }

  TextSelection get selection => value.selection;
  set selection(newSelection) {
    value = value.copyWith(selection: newSelection);
  }

  bool get validate => value.validate;

  void clear() {
    value = NumberEditingValue();
  }

  void inputChar(String char) {
    int cursorPosition = selection.base.offset;

    String newText = text;
    TextSelection newSelection = selection;
    bool validate = false;

    if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
      if (cursorPosition < 0) cursorPosition = text.length;
      newText = text.replaceRange(cursorPosition, cursorPosition, char);
      newSelection = TextSelection.collapsed(offset: cursorPosition + 1);
    } else if (char == "<") {
      if (cursorPosition > 0) {
        newSelection = TextSelection.collapsed(offset: cursorPosition - 1);
      }
    } else if (char == ">") {
      if (cursorPosition < text.length) {
        newSelection = TextSelection.collapsed(offset: cursorPosition + 1);
      }
    } else if (char == "x") {
      if (cursorPosition < 0) cursorPosition = text.length;
      if (text.isNotEmpty && cursorPosition > 0) {
        newText = text.replaceRange(cursorPosition-1, cursorPosition, "");
        newSelection = TextSelection.collapsed(offset: cursorPosition - 1);
      }
    } else if (char == "X") {
      newText = "";
      newSelection = const TextSelection.collapsed(offset: 0);
    } else if (char == "e") {
      validate = true;
    }

    value = value.copyWith(
      text: newText,
      selection: newSelection,
      validate: validate,
    );
  }
}

class NumberEditingValue {
  String text;
  TextSelection selection;
  bool validate;

  NumberEditingValue({
    this.text="",
    this.selection=const TextSelection.collapsed(offset: 0),
    this.validate=false,
  });

  NumberEditingValue copyWith({String? text, TextSelection? selection, bool? validate}) {
    return NumberEditingValue(
        text: text ?? this.text,
        selection: selection ?? this.selection,
        validate: validate ?? this.validate,
    );
  }
}
