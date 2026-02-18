import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/onboarding_flow/view/suggested_meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZenslamScreen extends StatelessWidget {
  const ZenslamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePath.appBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              CustomAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(flex: 1),
                      Text(
                        "Zenslam",
                        style: globalTextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Winning the Mental Game of Tennis",
                        style: globalTextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: BadgeWidget(
                              title: "120+",
                              subtitle: "Tennis Mental\nSessions",
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Expanded(
                            child: BadgeWidget(
                              title: "Expert",
                              subtitle: "Designed for\nPlayers",
                            ),
                          ),
                        ],
                      ),
                      Spacer(flex: 1),

                      CustomButton(
                        title: "Continue",
                        onTap: () {
                          Get.to(() => SuggestedMeditationScreen());
                        },
                        color: AppColors.primaryColor,
                        textColor: Colors.black,
                      ),
                      SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const BadgeWidget({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              IconsPath.leafLeft,
              // height: 55,
              // width: 55,
              height: MediaQuery.of(context).size.height * 0.128,
              width: MediaQuery.of(context).size.width * 0.128,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 50),
            Image.asset(
              IconsPath.leafRight,
              height: MediaQuery.of(context).size.height * 0.128,
              width: MediaQuery.of(context).size.width * 0.128,
              fit: BoxFit.contain,
            ),
          ],
        ),
        Positioned(
          bottom: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: globalTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  lineHeight: 1.3,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 11,
                  lineHeight: 1.3,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
