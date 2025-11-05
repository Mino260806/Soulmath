import 'dart:math';

abstract class NumberSet {
  const NumberSet();
  int pick(Random random);
}

class IntRange extends NumberSet {
  final int start;
  final int end;
  const IntRange(this.start, this.end);

  @override
  int pick(Random random) {
    return random.nextInt(end - start + 1) + start;
  }

}
