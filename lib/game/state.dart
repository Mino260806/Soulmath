import 'package:flutter/material.dart';

class GameStateProvider extends ChangeNotifier {
  late final List<GameState> _statesList;

  GameStateProvider(int playersCount) {
    _statesList = List.generate(playersCount, (i) => GameState());
  }
  
  GameState getState(int playerIndex) {
    return _statesList[playerIndex];
  }
  
  void setStatus(GameStatus newStatus, int playerIndex) {
    GameState state = getState(playerIndex);
    if (newStatus != state.status) {
      state.status = newStatus;
      notifyListeners();
    }
  }

  void setDuration(Duration newDuration, int playerIndex) {
    GameState state = getState(playerIndex);
    if (newDuration != state.duration) {
      state.duration = newDuration;
      notifyListeners();
    }
  }

  void firePlayerWon(int playerIndex) {
    for (int i=0; i<_statesList.length; i++) {
      GameState state = getState(i);
      if (playerIndex == i) {
        state.status = GameStatus.Won;
      } else {
        state.status = GameStatus.Lost;
      }
    }
    notifyListeners();
  }
}

class GameState {
  GameStatus status = GameStatus.InProgress;
  Duration duration = Duration.zero;
}

enum GameStatus {
  InProgress(""),
  Won("You won"),
  Lost("You lost"),
  Cancelled("Game cancelled"),
  ;

  final String message;
  const GameStatus(this.message);
}