import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';

enum IconPosition { before, after }

class CustomIconTextButton extends StatelessWidget {
  final String text;
  final String? iconPath; 
  final Color borderColor;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final IconPosition iconPosition;

  const CustomIconTextButton({
    super.key,
    required this.text,
    this.iconPath, 
    required this.borderColor,
    required this.textColor,
    required this.backgroundColor,
    required this.onPressed,
    this.iconPosition = IconPosition.before,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (iconPath != null) {
      children.add(
        Image.asset(iconPath!, height: 14, width: 14, color: textColor),
      );

      children.add( SizedBox(width: 6));
    }

    children.add(
      Text(
        text,
        style: getTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
    if (iconPath != null && iconPosition == IconPosition.after) {
      children = children.reversed.toList();
    }

    return SizedBox(
      width: 143,
      height: 28,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
