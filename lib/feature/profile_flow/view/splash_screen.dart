import 'package:zenslam/app/profile_flow/controller/splash_controller.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  Future<void> _precacheWelcomeImage(BuildContext context) async {
    try {
      await precacheImage(AssetImage(ImagePath.appBg), context);
    } catch (e) {
      debugPrint('Error pre-caching image: $e');
    }
  }

  final SplashScreenController controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheWelcomeImage(context);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.landingScreenBG),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Spacer(),
              Center(
                child: Text(
                  "Zenslam",
                  style: globalTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffffffff),
                  ),
                ),
              ),

              SizedBox(height: 15),
              SpinKitCircle(color: AppColors.primaryColor, size: 50),
              Spacer(),
              //SizedBox(height: 280),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.onButtonClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: const Color(0xFF1A1A1F),
                          border: Border.all(color: const Color(0xFF1A1A1F)),
                        ),
                        child: Center(
                          child: Text(
                            "Skip",
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        width: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 2000),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, pulseValue, child) {
                                return Container(
                                  height: 50 + (10 * pulseValue),
                                  width: 50 + (10 * pulseValue),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFFD4AF6A,
                                    ).withValues(alpha: 0.3 * (1 - pulseValue)),
                                  ),
                                );
                              },
                            ),

                            CircleAvatar(
                              backgroundColor: AppColors.primaryColor,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
