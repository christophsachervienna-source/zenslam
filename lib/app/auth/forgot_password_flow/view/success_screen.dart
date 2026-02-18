import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.appBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  ImagePath.successimage,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),

              Center(
                child: Text(
                  'Password Changed!',
                  style: globalTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xffffffff),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Center(
                child: Text(
                  'Your password has been changed ',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9E),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'successfully.',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A9A9E),
                  ),
                ),
              ),
              SizedBox(height: 30),
              CustomButton(
                title: "Go to home",
                onTap: () {
                  Get.offAll(() => NavBarScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
