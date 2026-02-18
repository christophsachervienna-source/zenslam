import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
        // controller.selectedIndex.value = -1;
      },
      child: Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: Color(0xffF6F6F6),
            shape: BoxShape.circle,
          ),
          child: Image.asset("assets/icons/close.png")),
    );
  }
}
