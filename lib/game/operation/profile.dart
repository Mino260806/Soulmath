
import 'package:soulmath/utils/number_set.dart';

class OperationProfileCollection {
  final String title;
  final List<OperationProfile> profiles;
  final bool preset;
  
  const OperationProfileCollection(this.title, this.profiles, {
    this.preset=false,
  });

  MutableOperationProfileCollection mutate() =>
      MutableOperationProfileCollection.from(this, preset: preset);
}

class OperationProfile {
  final OperationDetails details;
  final List<NumberSet> numberSets;
  final int weight;
  final bool enabled;

  const OperationProfile(this.details, this.numberSets, {
    this.weight=1,
    this.enabled=true,
  });

  MutableOperationProfile mutate({preset=false}) =>
      MutableOperationProfile.from(this, preset: preset);
}

enum OperationProfileCollectionPreset {
  // ! READ BEFORE ADDING A NEW PRESET
  // Each preset must have ranges for ALL VALUES of OperationDetails
  // and the ORDER of OperationProfile must be the same as in OperationDetails
  VeryEasy("Very Easy", [
    OperationProfile(OperationDetails.Addition, [IntRange(1, 10), IntRange(1, 10)]),
    OperationProfile(OperationDetails.Subtraction, [IntRange(1, 10), IntRange(1, 10)]),
    OperationProfile(OperationDetails.Multiplication, [IntRange(1, 10), IntRange(1, 10)]),
    OperationProfile(OperationDetails.Division, [IntRange(1, 50), IntRange(1, 5)]),
    OperationProfile(OperationDetails.Squaring, [IntRange(1, 10)]),
    OperationProfile(OperationDetails.SquareRooting, [IntRange(1, 100)]),
  ]),
  Easy("Easy", [
    OperationProfile(OperationDetails.Addition, [IntRange(1, 100), IntRange(1, 100)]),
    OperationProfile(OperationDetails.Subtraction, [IntRange(1, 100), IntRange(1, 100)]),
    OperationProfile(OperationDetails.Multiplication, [IntRange(1, 15), IntRange(1, 15)]),
    OperationProfile(OperationDetails.Division, [IntRange(1, 100), IntRange(1, 10)]),
    OperationProfile(OperationDetails.Squaring, [IntRange(1, 10)]),
    OperationProfile(OperationDetails.SquareRooting, [IntRange(1, 225)]),
  ]),
  Medium("Medium", [
    OperationProfile(OperationDetails.Addition, [IntRange(1, 1000), IntRange(1, 1000)]),
    OperationProfile(OperationDetails.Subtraction, [IntRange(1, 1000), IntRange(1, 1000)]),
    OperationProfile(OperationDetails.Multiplication, [IntRange(1, 99), IntRange(1, 99)]),
    OperationProfile(OperationDetails.Division, [IntRange(1, 999), IntRange(1, 10)]),
    OperationProfile(OperationDetails.Squaring, [IntRange(1, 99)]),
    OperationProfile(OperationDetails.SquareRooting, [IntRange(1, 10000)]),
  ]),
  Difficult("Difficult", [
    OperationProfile(OperationDetails.Addition, [IntRange(1, 10000), IntRange(1, 10000)]),
    OperationProfile(OperationDetails.Subtraction, [IntRange(1, 10000), IntRange(1, 10000)]),
    OperationProfile(OperationDetails.Multiplication, [IntRange(1, 999), IntRange(1, 99)]),
    OperationProfile(OperationDetails.Division, [IntRange(1, 9999), IntRange(1, 99)]),
    OperationProfile(OperationDetails.Squaring, [IntRange(1, 199)]),
    OperationProfile(OperationDetails.SquareRooting, [IntRange(1, 40000)]),
  ]),
  Hardcore("Hardcore", [
    OperationProfile(OperationDetails.Addition, [IntRange(1, 1000000), IntRange(1, 1000000)]),
    OperationProfile(OperationDetails.Subtraction, [IntRange(1, 1000000), IntRange(1, 1000000)]),
    OperationProfile(OperationDetails.Multiplication, [IntRange(1, 999), IntRange(1, 999)]),
    OperationProfile(OperationDetails.Division, [IntRange(1, 99999), IntRange(1, 99)]),
    OperationProfile(OperationDetails.Squaring, [IntRange(1, 999)]),
    OperationProfile(OperationDetails.SquareRooting, [IntRange(1, 1000000)]),
  ]),
  ;

  final String title;
  final List<OperationProfile> profiles;

  const OperationProfileCollectionPreset(this.title, this.profiles);
  
  OperationProfileCollection create() {
    return OperationProfileCollection(title, profiles, preset: true);
  }

  static List<OperationProfileCollection> createAll() {
    return values.map((e) => e.create()).toList();
  }
}

enum OperationAnswerInputType {
  Int
}

enum OperationDetails {
  Addition("Add", "add.svg",
      [ConfigurationDisplayItem.Range, "+", ConfigurationDisplayItem.Range]),
  Subtraction("Subtract", "subtract.svg",
      [ConfigurationDisplayItem.Range, "-", ConfigurationDisplayItem.Range]),
  Multiplication("Multiply", "multiply.svg",
      [ConfigurationDisplayItem.Range, "×", ConfigurationDisplayItem.Range]),
  Division("Divide", "divide.svg",
      [ConfigurationDisplayItem.Range, "÷", ConfigurationDisplayItem.Range]),
  Squaring("Square", "square.svg",
      [ConfigurationDisplayItem.Range, "²"],
      operandsCount: 1),
  SquareRooting("Root", "root.svg",
      ["√", ConfigurationDisplayItem.Range],
      operandsCount: 1),
  ;

  final String name;
  final String iconName;
  final int operandsCount;
  final OperationAnswerInputType inputType;
  final List<Object> configurationDisplay;
  const OperationDetails(this.name, this.iconName, this.configurationDisplay, {
    this.operandsCount=2,
    this.inputType=OperationAnswerInputType.Int,
  });
}

enum ConfigurationDisplayItem {
  Range;
}

class MutableOperationProfile {
  final OperationDetails details;
  List<NumberSet> numberSets;
  int weight;
  bool enabled;

  final bool preset;

  MutableOperationProfile(this.details, this.numberSets, {
    this.weight=1,
    this.enabled=true,
    this.preset=false,
  });

  factory MutableOperationProfile.from(OperationProfile profile, {preset=false}) {
    return MutableOperationProfile(profile.details, List.from(profile.numberSets),
        weight: profile.weight,
        enabled: profile.enabled,
        preset:  preset
    );
  }

  OperationProfile fasten() {
    return OperationProfile(details, List.unmodifiable(numberSets), enabled: enabled);
  }
}


class MutableOperationProfileCollection {
  late String title;
  List<MutableOperationProfile> profiles = [];

  late bool preset;

  MutableOperationProfileCollection();

  factory MutableOperationProfileCollection.from(OperationProfileCollection collection, {
    preset=false,
  }) {
    // We instantiate from a default collection because the given one might not
    // have all OperationProfile
    OperationProfileCollection defaultCollection = OperationProfileCollectionPreset.Easy.create();

    var instance = MutableOperationProfileCollection();
    instance.title = collection.title;
    instance.profiles = defaultCollection.profiles.map((e) =>
      e.mutate()..enabled = false).toList();
    instance.preset = preset;

    // The OperationProfile objects that are present in the given collection
    // will replace the default ones
    for (var profile in collection.profiles) {
      instance.profiles[profile.details.index] = profile.mutate(
        // delegate this property for easier access
        preset: preset,
      );
    }

    return instance;
  }

  OperationProfileCollection fasten() {
    return OperationProfileCollection(title,
      profiles.map((e) => e.fasten()).toList(), preset: preset);
  }
}
