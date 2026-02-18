import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/challenge_selection_screen.dart';
import 'package:zenslam/app/onboarding_flow/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final OnboardingController controller = Get.put(OnboardingController());
  late AnimationController _animationController;
  late Animation<Offset> titleSlideAnimation;
  late Animation<double> titleFadeAnimation;
  late Animation<Offset> subtitleSlideAnimation;
  late Animation<double> subtitleFadeAnimation;
  late Animation<Offset> bottomSlideAnimation;
  late Animation<double> bottomFadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    titleSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.5),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    subtitleSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 2.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    bottomSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });

    controller.currentStep.listen((_) {
      _restartAnimation();
    });
  }

  void _restartAnimation() {
    _animationController.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _precacheWelcomeImage(BuildContext context) async {
    try {
      await precacheImage(AssetImage(ImagePath.appBg), context);
    } catch (e) {
      debugPrint('Error pre-caching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheWelcomeImage(context);
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.landingScreenBG),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 15.0,
            ),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  SlideTransition(
                    position: titleSlideAnimation,
                    child: FadeTransition(
                      opacity: titleFadeAnimation,
                      child: Text(
                        controller.currentContent.title ?? '',
                        style: globalTextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffFFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SlideTransition(
                    position: subtitleSlideAnimation,
                    child: FadeTransition(
                      opacity: subtitleFadeAnimation,
                      child: Text(
                        controller.currentContent.subtitle,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9A9A9E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: bottomSlideAnimation,
                    child: FadeTransition(
                      opacity: bottomFadeAnimation,
                      child: _buildBottomSection(controller),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(OnboardingController controller) {
    if (controller.isLastStep) {
      return Column(
        children: [
          CustomButton(
            title: "Get Started",
            onTap: () {
              Get.offAll(() => const ChallengeSelectionScreen());
              controller.stopAudioAndNavigate();
            },
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9A9A9E),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.stopAudioAndNavigate();
                  Get.offAll(
                    () => LoginScreen(),
                    transition: Transition.noTransition,
                    duration: Duration.zero,
                    curve: Curves.linear,
                    opaque: false,
                  );
                },
                child: Text(
                  " Sign In",
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              controller.stopAudioAndNavigate();
              Get.to(() => const ChallengeSelectionScreen());
              // Get.to(() => NavBarScreen());
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
            onTap: () {
              controller.nextStep();
            },
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
      );
    }
  }
}
