import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  const ControlButton({required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1,
      child: Container(
        width: 80.0,
        height: 80.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            elevation: 0.0,
            onPressed: () {},
            child: this.icon,
          ),
        ),
      ),
    );
  }
}
