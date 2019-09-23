import 'dart:math';

import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

double _speed = 120.0;
const double _circleRadius = 15;

Offset _circlePosition;
int _score = 0;
double _delayTimeBeforeAddOtherBox = 1;

const whiteColor = Color(0xFFf7f4f7);
const blueColor = Color(0xFF01f5ab);
const backgroundColor = Color(0xFF1c2537);
const barColor = Color(0xFF131725);

final random = Random();

void speedUpGame() {
  _delayTimeBeforeAddOtherBox -= 0.0005;
  _speed += 0.7;
}

void resetGameSpeed() {
  _speed = 120;
  _delayTimeBeforeAddOtherBox = 1;
}

void restartGame() {
  resetGameSpeed();
  _score = 0;
}

class GamePad extends BaseGame {
  Size _screenDimension;
  static const TextConfig _textConfig =
  TextConfig(color: whiteColor, fontSize: 52);

  GamePad(this._screenDimension) {
    _circlePosition =
        Offset(_screenDimension.width / 2, _screenDimension.height / 2);
  }

  void onDragUpdate(DragUpdateDetails details) {
    _circlePosition =
        Offset(details.globalPosition.dx, _screenDimension.height / 2);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(backgroundColor, BlendMode.color);

    final catcher = BallComponent(_screenDimension);
    catcher.y = _circlePosition.dy;
    catcher.x = _circlePosition.dx;
    catcher.render(canvas);

    _textConfig.render(
        canvas,
        _score.toString(),
        Position.fromOffset(Offset(
            _screenDimension.width / 2, _screenDimension.height / 1.17)));

    super.render(canvas);
  }

  bool _generateGreenBox(int whiteBoxCount) {
    if (whiteBoxCount == 0) return false;

    final rNumber = random.nextInt(whiteBoxCount);
    return rNumber >= 2 && (rNumber % 2) == 1;
  }

  double creationTime = 0;
  int whiteBoxCount = 0;

  @override
  void update(double t) {
    super.update(t);
    creationTime += t;

    // If reached the max speed then reset the game speed
    if(_delayTimeBeforeAddOtherBox <= 0 || _speed >= 250) {
      resetGameSpeed();
    }

    if (creationTime >= _delayTimeBeforeAddOtherBox) {
      creationTime = 0;
      SquareComponent newSquare;

      if (_generateGreenBox(whiteBoxCount)) {
        whiteBoxCount = 0;
        newSquare = SquareComponent(_screenDimension, true);
      } else {
        whiteBoxCount++;
        newSquare = SquareComponent(_screenDimension, false);
      }
      add(newSquare);
    }
  }
}

class BallComponent extends PositionComponent {
  BallComponent(this._screenDimension)
      : _circlePainter = Paint()
    ..color = blueColor
    ..style = PaintingStyle.fill,
        _linePainter = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill;

  final Size _screenDimension;
  Paint _circlePainter;
  Paint _linePainter;

  @override
  void update(double t) {}

  static const minCirclePosiX = 35.0;
  double get maxCirclePosiX => _screenDimension.width / 1.1;

  @override
  void render(Canvas c) {

    final r = Rect.fromCenter(
        center: Offset(_screenDimension.width / 2, y),
        width: maxCirclePosiX,
        height: _circleRadius * 2);

    c.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(_circleRadius)),
        _linePainter);

    final lastPosiX = x < minCirclePosiX ?
    minCirclePosiX : x > maxCirclePosiX ? maxCirclePosiX : x;

    c.drawCircle(Offset(lastPosiX, y), _circleRadius, _circlePainter);
  }
}

enum Direction { left, right }

class SquareComponent extends PositionComponent {
  final bool isGreenBox;
  Direction direction;
  final Size _screenDimension;

  SquareComponent(this._screenDimension, this.isGreenBox) {
    _squarePainter = Paint()
      ..color = isGreenBox ? blueColor : whiteColor
      ..style = PaintingStyle.fill;

    x = random.nextInt(_screenDimension.width.toInt()).toDouble();

    direction =
    (x > (_screenDimension.width / 2)) ? Direction.left : Direction.right;
  }

  Paint _squarePainter;

  bool canDestroy = false;

  @override
  void update(double t) {
    y += t * _speed;

    switch (direction) {
      case Direction.left:
        x -= 0.88;
        break;
      case Direction.right:
        x += 0.88;
        break;
    }

    final cx = _circlePosition.dx;
    final cy = _circlePosition.dy;

    bool betweenXBall = x > (cx - _circleRadius) && x < (cx + _circleRadius);
    bool betweenYBall = y > (cy - _circleRadius) && y < (cy + _circleRadius);
    bool afterYBall = y > (cy * 1.4);

    if (betweenXBall && betweenYBall && isGreenBox) {
      _score++;
      speedUpGame();
      _scheduleDestroy();
    }else if(betweenXBall && betweenYBall && !isGreenBox) {
      restartGame();
      _scheduleDestroy();
    } else if (afterYBall) {
      _scheduleDestroy();
    }
  }

  //TODO: Delay before destroy this object and play some animation
  _scheduleDestroy() {
    //await Future.delayed(Duration(seconds: 2));
    canDestroy = true;
  }

  @override
  bool destroy() => canDestroy;

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromCenter(center: Offset(x, y),
        width: _circleRadius, height: _circleRadius), _squarePainter);
  }
}
