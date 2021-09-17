import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'control_panel.dart';
import 'direction.dart';
import 'piece.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late int upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  late double screenWidth, screenHeight;
  int step = 30;
  int length = 5;
  late Offset foodPosition;
  Piece? food;
  int score = 0;
  double speed = 1.0;
  List<Offset> positions = [];
  Direction direction = Direction.right; //default는 right로 설정
  Timer? timer;

  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (Timer timer) {
      setState(() {});
    });
  }

  Widget getControls() {
    return ControlPanel(onTapped: (Direction Direction) {
      direction = Direction;
    });
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  void restart() {
    length = 5;
    score = 0;
    speed = 1;
    positions = [];
    direction = getRandomDirection(); //새로 시작할 때 새로운 자리에서
    changeSpeed();
  } // 모두 리셋

  @override
  initState() {
    super.initState();
    restart();
  }

  int getNearedstTens(int num) {
    int output;
    output = (num ~/ step) * step;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  Offset getRandomPosition() {
    Offset position;
    int posX = Random().nextInt(upperBoundX) + lowerBoundX;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;

    position = Offset(
        getNearedstTens(posX).toDouble(), getNearedstTens(posY).toDouble());

    return position;
  } //랜덤 포지션을 만듦 > 뱀이 나타날 곳

  void draw() async {
    if (positions.length == 0) {
      positions.add(getRandomPosition()); //랜덤 포지션이 스크린에 그려질 것
    }
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]); //피스 추가
    }
    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1]; //움직임 >
    }
    positions[0] =
        await getNextPosition(positions[0]); //움직일 수 있도록 만들어주기 (다음 위치 지정)
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundY && direction == Direction.up) {
      return true;
    }
    return false;
  } //벽에 부딪힐 경우

  void showGameOverDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blue,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text(
              "Game Over",
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              "Your game is over. Your score is " + score.toString() + ".",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    restart(); //다시 시작하도록
                  },
                  child: Text(
                    "Restart",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }

  Future<Offset> getNextPosition(Offset position) async {
    //position = 뱀 머리
    late Offset nextPosition;

    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy); //몸통 하나 크기 만큼 움직여
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    if (detectCollision(position) == true) {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }
      await Future.delayed(
          Duration(milliseconds: 200), () => showGameOverDialog());
      return position;
    } //게임 끝내기
    return nextPosition;
  }

  void drawFood() {
    foodPosition = getRandomPosition();

    if (foodPosition == positions[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.25;
      foodPosition = getRandomPosition();
    }
    food = Piece(
      posX: foodPosition.dx.toInt(),
      posY: foodPosition.dy.toInt(),
      size: step,
      color: Colors.red,
      isAnimated: true,
    );
  }

  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
    drawFood();
    for (var i = 0; i < length; ++i) {
      if (i >= positions.length) {
        continue; //먹이 안먹으면 크기 증가 없음
      }

      pieces.add(
        Piece(
          posX: positions[i].dx.toInt(),
          posY: positions[i].dy.toInt(),
          size: step,
          color: i.isEven ? Colors.red : Colors.green,
          isAnimated: false,
        ),
      );
    }

    return pieces;
  }

  Widget getScore() {
    return Positioned(
        top: 80.0,
        right: 50.0,
        child: Text(
          "Score :" + score.toString(),
          style: TextStyle(fontSize: 30, color: Colors.white),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context)
        .size
        .height; //스마트폰 크기 다 다르니까 MediaQuery 써서 유저 스크린 사이즈
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundY = step;
    lowerBoundX = step;

    upperBoundY = screenHeight.toInt() - step;
    upperBoundX = screenWidth.toInt() - step;

    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: Stack(
          children: [
            Stack(
              children: getPieces(), // 피스가 스크린에 나오도록  return
            ),
            getControls(),
            getScore(),
            food != null ? food! : Container(),
          ],
        ),
      ),
    );
  }
}
