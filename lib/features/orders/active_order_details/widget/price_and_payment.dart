import 'package:ZipBee/core/common/styles/global_text_style.dart';
import 'package:ZipBee/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PriceAndPayment extends StatelessWidget {
  const PriceAndPayment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              "Total",
              style: getTextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "\$24.00",
              style: getTextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Spacer(),
    
        Image.asset(IconPath.visa, height: 22.h, width: 24.w),
        SizedBox(width: 4),
        Text("****456", style: getTextStyle(fontSize: 13)),
      ],
    );
  }
}


