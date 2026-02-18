import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/profile_flow/widgets/select_goal_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  final String userName;

  const WelcomeScreen({super.key, this.userName = ""});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        //backgroundColor: Color(0xff25465A),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePath.welcome),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              CustomAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.userName.isNotEmpty) ...[
                                const SizedBox(height: 30),
                                SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.0, 1.5),
                                        end: const Offset(0.0, 0.0),
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: const Interval(
                                            0.3,
                                            1.0,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                      ),
                                  child: FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: const Interval(
                                              0.3,
                                              1.0,
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                        ),
                                    child: Text(
                                      "Welcome, ${widget.userName} 👋",
                                      style: globalTextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xffffffff),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0.0, 2.0),
                                        end: const Offset(0.0, 0.0),
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: const Interval(
                                            0.5,
                                            1.0,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                      ),
                                  child: FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: const Interval(
                                              0.5,
                                              1.0,
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                        ),
                                    child: Text(
                                      "This is your space to recharge, refocus, and grow stronger.",
                                      style: globalTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF9A9A9E),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Animated continue button
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: const Offset(0.0, 0.0),
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.7,
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.7,
                                1.0,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          child: CustomButton(
                            title: "Continue",
                            onTap: () {
                              Get.to(() => SelectGoalScreen());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
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
