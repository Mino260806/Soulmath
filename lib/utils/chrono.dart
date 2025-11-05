import 'dart:async';

import 'package:flutter/cupertino.dart';

class Chrono {
  DateTime? _startTime;
  DateTime? _startPause;

  bool get isStarted => _startTime != null;

  void start() {
    _startTime = DateTime.now();
  }

  Duration stop() {
    Duration elapsedTime = getElapsedTime();

    _startTime = null;

    return elapsedTime;
  }

  void pause() {
    if (_startTime == null) throw UnsupportedError("Chrono was not started");

    _startPause = DateTime.now();
  }

  void resume() {
    if (_startTime == null) throw UnsupportedError("Chrono was not started");
    if (_startPause == null) throw UnsupportedError("Chrono was not paused");

    Duration pauseDuration = DateTime.now().difference(_startPause!);
    _startTime = _startTime!.add(pauseDuration);
    _startPause = null;
  }

  Duration getElapsedTime() {
    if (_startTime == null) throw UnsupportedError("Chrono was not started");

    return DateTime.now().difference(_startTime!);
  }
}

class ChronoWidget extends StatefulWidget {
  final Chrono chrono;
  final TextStyle? textStyle;
  ChronoWidget({required this.chrono, this.textStyle});

  @override
  State<ChronoWidget> createState() => _ChronoWidgetState();
}

class _ChronoWidgetState extends State<ChronoWidget> {
  Timer? _timer;

  @override
  void initState() {
    const refreshRate = Duration(milliseconds: 90);
    _timer = Timer.periodic(refreshRate, (timer) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.chrono.isStarted ?
    Text(
      "${widget.chrono.getElapsedTime().inSecondsTwoFloatingPoint}",
      style: widget.textStyle,
    ): Container();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

extension BetterDuration on Duration {
  double get inSecondsTwoFloatingPoint => (inMilliseconds / 10).floor() / 100.0;
}
