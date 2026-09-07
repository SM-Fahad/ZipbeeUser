import 'package:flutter/material.dart';

class TwoSideIconText extends StatelessWidget {
  final String leftImage;
  final String leftText;
  final String rightImage;
  final String rightText;

  const TwoSideIconText({
    super.key,
    required this.leftImage,
    required this.leftText,
    required this.rightImage,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Image.asset(leftImage, width: 24, height: 24)),
              SizedBox(width: 8),
              Flexible(child: Text(leftText, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),

        SizedBox(width: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Image.asset(rightImage, width: 17, height: 17)),
              SizedBox(width: 8),
              Flexible(child: Text(rightText, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ],
    );
  }
}
