import 'package:catcher/src/game_pad.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  final util = Flame.util;
  util.fullScreen();

  final _screenDimensions = await util.initialDimensions();

  final game = GamePad(_screenDimensions);

  final dragRecognizer = HorizontalDragGestureRecognizer();
  dragRecognizer.onUpdate = game.onDragUpdate;

  runApp(game.widget);
  util.addGestureRecognizer(dragRecognizer);
}

