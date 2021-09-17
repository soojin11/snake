import 'package:flutter/material.dart';
import 'control_button.dart';
import 'direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction) onTapped;
  const ControlPanel({required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 50.0,
      child: Row(
        children: [
          Expanded(
            //빈 공간을 다 사용할 수 있도록
            child: Row(
              children: [
                Expanded(child: Container()), //빈공간
                ControlButton(
                  onPressed: () {
                    onTapped(Direction.left);
                  },
                  icon: Icon(Icons.arrow_left),
                )
              ],
            ),
          ),
          Expanded(
              child: Column(
            children: [
              ControlButton(
                onPressed: () {
                  onTapped(Direction.up);
                },
                icon: Icon(Icons.arrow_drop_up),
              ),
              SizedBox(
                height: 70,
              ),
              ControlButton(
                onPressed: () {
                  onTapped(Direction.down);
                },
                icon: Icon(Icons.arrow_drop_down),
              ),
            ],
          )),
          Expanded(
            //빈 공간을 다 사용할 수 있도록
            child: Row(
              children: [
                ControlButton(
                  onPressed: () {
                    onTapped(Direction.right);
                  },
                  icon: Icon(Icons.arrow_right),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
