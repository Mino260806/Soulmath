extension ListExtension<E> on List<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) sync* {
    int index = 0;
    for (var element in this) {
      yield f(index, element);
      index++;
    }
  }

  void forEachIndexed(void Function(int index, E element) f) {
    for (int index = 0; index < length; index++) {
      f(index, this[index]);
    }
  }
}