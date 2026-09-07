import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';

class Reviews extends StatelessWidget {
  const Reviews({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 18),
        Icon(Icons.star, color: Colors.amber, size: 18),
        Icon(Icons.star, color: Colors.amber, size: 18),
        Icon(Icons.star, color: Colors.amber, size: 18),
        Icon(Icons.star, color: Colors.amber, size: 18),
        SizedBox(width: 6),
        Text("5/5", style: getTextStyle()),
        Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            '(243 Reviews)',
            style: getTextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }
}
