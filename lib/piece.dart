import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final int posX, posY, size;
  final bool isAnimated;
  final Color color;
  const Piece({
    required this.color,
    required this.size,
    required this.posX,
    required this.posY,
    this.isAnimated = false,
  });
  @override
  _pieceState createState() => _pieceState();
}

class _pieceState extends State<Piece> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  initState() {
    super.initState();
    _animationController = AnimationController(
        lowerBound: 0.25,
        upperBound: 1.0,
        duration: Duration(milliseconds: 1000),
        vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController
            .reset(); //먹이 다시 생성 opacity를 애니메이트..? => 먹이 투명도 주는 애니메이션
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward(); // 애니메이션 시작
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.posY.toDouble(),
      left: widget.posX.toDouble(),
      child: Opacity(
        opacity: widget.isAnimated ? _animationController.value : 1,
        child: Container(
          width: widget.size.toDouble(),
          height: widget.size.toDouble(),
          decoration: BoxDecoration(
              //뱀 모양 만들어주기 위해
              color: widget.color,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(width: 2.0, color: Colors.white)),
        ),
      ),
    );
  }
}
