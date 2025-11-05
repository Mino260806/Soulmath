import 'dart:math';

import 'package:soulmath/game/operation/profile.dart';


class OperationQuestion {
  final OperationAnswerInputType inputType;
  final String representation;
  final Object correctAnswer;

  OperationQuestion({required this.inputType, required this.representation, required this.correctAnswer});

  bool verifyAnswer(Object answer) {
    return correctAnswer == answer;
  }
}


class OverallOperationSupplier {
  final List<OperationSupplier> _suppliers = [];
  late final int _totalWeight;

  final Random _random = Random();

  int _preparedQuestionsKey = -1;
  List<OperationQuestion> _preparedQuestions = [];
  List<List<int>> _preparedQuestionsOrder = [];

  OverallOperationSupplier(OperationProfileCollection profileCollection) {
    _totalWeight = profileCollection.profiles.fold(0,
            (sum, profile) => sum + (profile.enabled? profile.weight: 0));
    for (OperationProfile profile in profileCollection.profiles) {
      if (profile.enabled) {
        _suppliers.add(OperationSupplier.from(profile));
      }
    }
  }

  OperationQuestion getQuestion() {
    // Choose a random operation supplier based on profile weights
    OperationSupplier supplier = _getRandomOperationProfile();

    return supplier.getQuestion(_random);
  }

  void prepareQuestions(int key, int count, int playersCount) {
    if (_preparedQuestionsKey != key) {
      _preparedQuestionsKey = key;
      _preparedQuestions = List.generate(count, (index) => getQuestion());


      // Generate a list of lists containing each the shuffled order of questions
      // for a specific player
      // example [5, 7, 2, 1, 0, 6 ,9, 3, 4, 8]
      _preparedQuestionsOrder = List.generate(playersCount,
              (_) =>
          List.generate(count, (index) => index)
            ..shuffle(_random));
    }
  }

  OperationQuestion getPreparedQuestion(int key, int playerIndex) {
    if (key != _preparedQuestionsKey) {
      throw UnsupportedError("Unknown key. Expected $_preparedQuestionsKey, got $key");
    }

    int index = _preparedQuestionsOrder[playerIndex][0];
    if (_preparedQuestionsOrder[playerIndex].isNotEmpty) {
      _preparedQuestionsOrder[playerIndex].removeAt(0);
    }
    return _preparedQuestions[index];
  }

  OperationSupplier _getRandomOperationProfile() {
    int targetIndex = _random.nextInt(_totalWeight);
    int cumulativeIndex = 0;
    for (var supplier in _suppliers) {
      cumulativeIndex += supplier.weight;

      if (targetIndex < cumulativeIndex) {
        return supplier;
      }
    }

    throw RangeError.range(targetIndex, 0, _totalWeight);
  }
}


abstract class OperationSupplier {
  final OperationProfile profile;
  late final int weight;

  OperationSupplier(this.profile) {
    weight = profile.weight;
  }
  
  OperationQuestion getQuestion(Random random);

  factory OperationSupplier.from(OperationProfile profile) {
    switch (profile.details) {
      case OperationDetails.Addition:
        return AdditionOperationSupplier(profile);
      case OperationDetails.Subtraction:
        return SubtractionOperationSupplier(profile);
      case OperationDetails.Multiplication:
        return MultiplicationOperationSupplier(profile);
      case OperationDetails.Division:
        return DivisionOperationSupplier(profile);
      case OperationDetails.Squaring:
        return SquaringOperationSupplier(profile);
      case OperationDetails.SquareRooting:
        return SquareRootingOperationSupplier(profile);
      default:
        throw UnsupportedError("Unknown OperationDetails: ${profile.details}");
    }
  }
}

class AdditionOperationSupplier extends OperationSupplier {
  AdditionOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);
    int b = profile.numberSets[1].pick(random);

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "$a + $b",
      correctAnswer: a + b,
    );
  }
}

class SubtractionOperationSupplier extends OperationSupplier {
  SubtractionOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);
    int b = profile.numberSets[1].pick(random);

    // We want a to be the biggest
    if (a < b) {
      int c = a;
      a = b;
      b = c;
    }

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "$a - $b",
      correctAnswer: a - b,
    );
  }
}

class MultiplicationOperationSupplier extends OperationSupplier {
  MultiplicationOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);
    int b = profile.numberSets[1].pick(random);

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "$a × $b",
      correctAnswer: a * b,
    );
  }
}

class DivisionOperationSupplier extends OperationSupplier {
  DivisionOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);
    int b = profile.numberSets[1].pick(random);

    // We want a to be the biggest
    if (a < b) {
      int c = a;
      a = b;
      b = c;
    }

    a = (a / b).floor() * b;

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "$a ÷ $b",
      correctAnswer: a / b,
    );
  }
}

class SquaringOperationSupplier extends OperationSupplier {
  SquaringOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "$a²",
      correctAnswer: a * a,
    );
  }
}

class SquareRootingOperationSupplier extends OperationSupplier {
  SquareRootingOperationSupplier(super.profile);

  @override
  OperationQuestion getQuestion(Random random) {
    int a = profile.numberSets[0].pick(random);

    int root = sqrt(a).floor();
    a =  root * root;

    return OperationQuestion(
      inputType: profile.details.inputType,
      representation: "√$a",
      correctAnswer: root,
    );
  }
}
