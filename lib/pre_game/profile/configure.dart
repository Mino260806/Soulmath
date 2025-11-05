import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soulmath/game/operation/profile.dart';
import 'package:soulmath/utils/list_extensions.dart';
import 'package:soulmath/utils/number_set.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilesConfigurationSheet extends StatefulWidget {
  final List<OperationProfileCollection> allProfileCollections;
  int selectedIndex;
  final Function(int)? onStart;

  ProfilesConfigurationSheet({
    super.key, 
    required this.allProfileCollections, 
    required this.selectedIndex,
    this.onStart,
  });

  @override
  State<ProfilesConfigurationSheet> createState() => _ProfilesConfigurationSheetState();
}

class _ProfilesConfigurationSheetState extends State<ProfilesConfigurationSheet> {
  late _ProfileAdvancedPanelController _controller;
  late MutableOperationProfileCollection _profileCollection;
  late int _selectedIndex;

  @override
  void initState() {
    _controller = _ProfileAdvancedPanelController();
    _profileCollection = widget.allProfileCollections[widget.selectedIndex].mutate();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileConfigurationContainer(_controller),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 5.0),
            child: DropdownButton<int>(
              value: _selectedIndex,
              items: List.generate(widget.allProfileCollections.length+1,
                      (i) => DropdownMenuItem<int>(
                        value: i,
                        child:
                        i < widget.allProfileCollections.length
                            ? Text(widget.allProfileCollections[i].title)
                            : Text("Create Profile"),
                      )),
              onChanged: (int? selection) {
                if (selection != null) {
                  setState(() {
                    switchProfileCollection(selection);
                  });
                }
              },
            ),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 20.0,
            runSpacing: 10.0,
            children: _profileCollection.profiles.mapIndexed((i, p) =>
                _OperationButton(p, _controller, onEnabledChange: buttonEnabledChangeGuard,
                  key: ValueKey(_selectedIndex * OperationDetails.values.length + i))).toList(),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              FilledButton(
                onPressed: () {
                  saveProfileCollection();
                  Navigator.of(context).pop();
                  widget.onStart?.call(_selectedIndex);
                },
                child: const Text("Start"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ensures that at least one profile is enabled
  bool buttonEnabledChangeGuard(bool newState) {
    bool accept = newState || _profileCollection.profiles.fold(0,
            (v, e) => v + (e.enabled? 1: 0)) >= 2;
    return accept;
  }

  void saveProfileCollection() {
    widget.allProfileCollections[_selectedIndex] = _profileCollection.fasten();
  }

  void switchProfileCollection(int newIndex) {
    _controller.hide();
    saveProfileCollection();

    if (newIndex < widget.allProfileCollections.length) {
      _profileCollection = widget.allProfileCollections[newIndex].mutate();
      _selectedIndex = newIndex;
    }
    else {
      // TODO ask for profile title, save profile locally, add delete button
      _profileCollection = MutableOperationProfileCollection.from(
        OperationProfileCollectionPreset.Medium.create(), preset: false
      );
      _profileCollection.title = "Profile1";
      widget.allProfileCollections.add(_profileCollection.fasten());
      _selectedIndex = newIndex;
    }
  }
}

class _OperationButton extends StatefulWidget {
  final MutableOperationProfile profile;
  final _ProfileAdvancedPanelController controller;
  
  final bool Function(bool newState)? onEnabledChange;

  const _OperationButton(this.profile, this.controller, {super.key, this.onEnabledChange});

  @override
  State<_OperationButton> createState() => _OperationButtonState();
}

class _OperationButtonState extends State<_OperationButton> {
  MutableOperationProfile? _profile;
  
  @override
  void initState() {
    _profile = widget.profile;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: () {
            widget.controller.setTargetProfile(_profile);
          },
          child: IconButton.filledTonal(
            onPressed: () {
              widget.controller.hide();
              bool newState = !(_profile!.enabled);
              bool? canChange = widget.onEnabledChange?.call(newState);
              if (canChange == null || canChange) {
                setState(() {
                  _profile!.enabled = newState;
                });
              }
            },
            isSelected: _profile!.enabled,
            iconSize: 30.0,
            icon: SvgPicture.asset(
              "assets/image/${_profile!.details.iconName}",
              // color: Colors.black,
              width: 20,
              height: 20,
            ),
          ),
        ),
        Text(_profile!.details.name),
      ],
    );
  }
}

class _ProfileConfigurationContainer extends StatefulWidget {
  final _ProfileAdvancedPanelController controller;
  const _ProfileConfigurationContainer(this.controller);

  @override
  State<_ProfileConfigurationContainer> createState() => _ProfileConfigurationContainerState();
}

class _ProfileConfigurationContainerState extends State<_ProfileConfigurationContainer> {
  final maxOperandsCount = OperationDetails.values.map((e) => e.operandsCount)
      .fold(OperationDetails.Addition.operandsCount,
          (v, e) => e > v? e: v);

  late _ProfileAdvancedPanelController _controller;
  late List<_RangeEditControllerPair> _rangesControllers;

  @override
  void initState() {
    _controller = widget.controller;
    _rangesControllers = List.generate(maxOperandsCount,
            (index) => _RangeEditControllerPair());

    _controller.addListener(() {
      if (_controller.profile != null) {
        for (int i=0; i<_controller.profile!.numberSets.length; i++) {
          var range = _controller.profile!.numberSets[i] as IntRange;
          _rangesControllers[i].setProfile(_controller.profile, i);
          _rangesControllers[i].from = range.start;
          _rangesControllers[i].to = range.end;
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (BuildContext context, value, Widget? child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: _controller.show ? const EdgeInsets.only(bottom: 30)
                : EdgeInsets.zero,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _controller.show ? Column(
                key: ValueKey(_controller.profile!.details.index),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0),
                    child: Text(
                      _controller.profile!.details.name,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: generateConfigRow(),
                  ),
                ],
              ): Container(),
            ),
          ),
        );
      },
    );
  }

  List<Widget> generateConfigRow() {
    int rangesIndex = 0;
    return _controller.profile!.details.configurationDisplay.mapIndexed((i, e) {
      if (e is String) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(e, style: const TextStyle(fontSize: 30)),
        );
      } else if (e is ConfigurationDisplayItem) {
        switch (e) {
          case ConfigurationDisplayItem.Range:
            int myIndex = rangesIndex;
            rangesIndex++;
            return _ProfileConfigurationRangeEdit(_rangesControllers[myIndex]);
          default:
            throw UnsupportedError("Unknown configuration item: $e");
        }
      }
      else {
        throw UnsupportedError("Unknown configuration item: $e");
      }
    }).toList();
  }
}

class _ProfileAdvancedPanelController extends ValueNotifier<MutableOperationProfile?> {
  _ProfileAdvancedPanelController(): super(null);

  bool get show => value != null;
  MutableOperationProfile? get profile => value;

  void hide() {
    value = null;
  }
  
  void setTargetProfile(MutableOperationProfile? profile) {
    value = profile;
  }
  
}

class _ProfileConfigurationRangeEdit extends StatefulWidget {
  _RangeEditControllerPair controllerPair;

  _ProfileConfigurationRangeEdit(this.controllerPair);

  @override
  State<_ProfileConfigurationRangeEdit> createState() => _ProfileConfigurationRangeEditState();
}

class _ProfileConfigurationRangeEditState extends State<_ProfileConfigurationRangeEdit> {
  late _RangeEditControllerPair _controllerPair;

  @override
  void initState() {
    _controllerPair = widget.controllerPair;
  }

  @override
  Widget build(BuildContext context) {
    // TODO check that numbers are within boundaries AND that "to" doesn't exceed "from"
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: _controllerPair.fromController,
              enabled: !_controllerPair.profile!.preset,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: "From",
              ),
            ),
          ),
          const SizedBox(width: 10,),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _controllerPair.toController,
              enabled: !_controllerPair.profile!.preset,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: "To",
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _RangeEditControllerPair {
  MutableOperationProfile? profile;
  int _index = -1;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  _RangeEditControllerPair() {
    fromController.addListener(updateProfile);
    toController.addListener(updateProfile);
  }

  void setProfile(MutableOperationProfile? profile, int index) {
    this.profile = profile;
    this._index = index;
  }
  
  int? get from => int.tryParse(fromController.text);
  set from(int? newFrom) {
    fromController.text = newFrom.toString();
  }

  int? get to => int.tryParse(toController.text);
  set to(int? newTo) {
    toController.text = newTo.toString();
  }

  void updateProfile() {
    if (profile != null && from != null && to != null) {
      profile!.numberSets[_index] = IntRange(from!, to!);
    }
  }
}