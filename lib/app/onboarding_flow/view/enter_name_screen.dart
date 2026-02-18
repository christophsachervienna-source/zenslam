import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/onboarding_flow/view/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:get/get.dart';

class EnterNameScreen extends StatelessWidget {
  const EnterNameScreen({super.key});

  Future<void> _precacheWelcomeImage(BuildContext context) async {
    try {
      await precacheImage(AssetImage(ImagePath.welcome), context);
    } catch (e) {
      debugPrint('Error pre-caching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheWelcomeImage(context);
    });

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21.0,
                    vertical: 15.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's your name?",
                          style: globalTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffffffff),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Full Name",
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffffffff),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffffffff),
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter your Full Name",
                            hintStyle: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9A9A9E),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF9A9A9E),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF9A9A9E),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF9A9A9E),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters long';
                            }
                            if (!RegExp(
                              r'^[a-zA-Z\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Name can only contain letters and spaces';
                            }
                            return null;
                          },
                        ),
                        Spacer(),
                        CustomButton(
                          title: "Continue",
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              final name = nameController.text.trim();
                              await SharedPrefHelper.saveUserName(name);
                              // Save name to SharedPreferences for later use in registration
                              await SharedPrefHelper.saveOnboardingName(name);

                              // Update ProfileController if it's already in memory
                              if (Get.isRegistered<ProfileController>()) {
                                Get.find<ProfileController>().fullName.value =
                                    name;
                              }

                              debugPrint('✅ Saved onboarding name: $name');

                              Get.to(
                                () => WelcomeScreen(userName: name),
                                transition: Transition.fadeIn,
                                duration: Duration(milliseconds: 400),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
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
