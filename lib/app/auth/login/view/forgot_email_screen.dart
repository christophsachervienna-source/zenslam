import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/auth/forgot_password_flow/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotEmailScreen extends StatelessWidget {
  ForgotEmailScreen({super.key});

  final AuthController controller = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xff94A3B8), width: 1.5),
    );
  }

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
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 15,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Forgot Password',
                          style: globalTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No worries! Enter your email address below and we will send you a code to reset password.',
                        textAlign: TextAlign.center,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9A9A9E),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Email',
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textWidthBasis: null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9A9A9E),
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          errorBorder: _inputBorder(),
                          focusedErrorBorder: _inputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        validator: controller.validateEmail,
                      ),
                      Obx(
                        () => controller.errorMessage.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: globalTextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      const Spacer(),
                      CustomButton(
                        title: "Send Reset Code",
                        onTap: () async {
                          controller.errorMessage.value = '';
                          controller.sendResetCode();
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
