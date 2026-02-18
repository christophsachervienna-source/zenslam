import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/image_path.dart';
import 'package:zenslam/core/global_widegts/custom_app_bar.dart';
import 'package:zenslam/core/global_widegts/custom_button.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/onboarding_flow/controller/selected_controller.dart';
import 'package:zenslam/app/onboarding_flow/view/enter_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class SelectMostImportantScreen extends StatelessWidget {
  SelectMostImportantScreen({super.key, this.isFromPreference = false});
  final bool isFromPreference;

  SelectedController controller = Get.put(SelectedController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && isFromPreference && result != true) {
          controller.resetToInitial();
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImagePath.appBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomAppBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21.0,
                    vertical: 15.0,
                  ),
                  child: Text(
                    "What's most important to you right now?",
                    style: globalTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Select what matters most to you",
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9A9A9E),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (controller.availableMatters.isEmpty) {
                      return Center(
                        child: Text(
                          'No options available',
                          style: globalTextStyle(
                            fontSize: 16,
                            color: Color(0xFF9A9A9E),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.availableMatters.length,
                        itemBuilder: (context, index) {
                          final matter = controller.availableMatters[index];
                          return Obx(() {
                            final isSelected = controller.isSelected(
                              matter.name,
                            );
                            return GestureDetector(
                              onTap: () => controller.toggleImportant(
                                matter.name,
                                matter.image,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isSelected
                                      ? const Color(0xFF2E2E2E)
                                      : const Color(0xFF2e3236),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : const Color(0xffE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Check if the image string is a URL
                                    (matter.image.startsWith('http') ||
                                            matter.image.startsWith('https'))
                                        ? Image.network(
                                            matter.image,
                                            height: 24,
                                            width: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.image_not_supported,
                                                    size: 24,
                                                    color: Colors.grey,
                                                  );
                                                },
                                          )
                                        : Text(
                                            matter.image,
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        matter.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Container(
                                              height: 8,
                                              width: 8,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF2e3236),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: Container(
                                                  height: 4,
                                                  width: 4,
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(
                                                          0xFFD4AF6A,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Obx(() {
                    final selected =
                        controller.importantModel.value.selectedImportants;
                    return CustomButton(
                      title: isFromPreference ? 'Done' : "Next",
                      onTap: selected.isEmpty
                          ? null
                          : () {
                              if (isFromPreference) {
                                Get.back(result: true);
                              } else {
                                Get.to(() => EnterNameScreen());
                              }
                            },
                    );
                  }),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
