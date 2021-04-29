import 'package:flutter/material.dart';

class TransparentBackground extends StatelessWidget {
  TransparentBackground(
      {this.widget, this.horizontal_padding, this.vertical_padding});

  final Widget widget;
  final double vertical_padding;
  final double horizontal_padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            vertical: vertical_padding, horizontal: horizontal_padding),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        child: widget);
  }
}
