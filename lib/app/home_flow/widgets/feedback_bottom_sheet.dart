import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:zenslam/app/favorite_flow/controller/feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FeedbackBottomSheet extends StatelessWidget {
  FeedbackBottomSheet({super.key});
  final FeedbackController controller = Get.put(FeedbackController());

  String _getTitleHint(String feedbackType) {
    switch (feedbackType) {
      case 'Meditation Topic Request':
        return "What meditation topic would you like?";
      case 'Feature Suggestion':
        return "What feature would you like to see?";
      default:
        return "Title";
    }
  }

  String _getDescriptionHint(String feedbackType) {
    switch (feedbackType) {
      case 'Meditation Topic Request':
        return "Describe the meditation topic or theme you'd like us to create...";
      case 'Feature Suggestion':
        return "Describe your feature idea and how it would help you...";
      default:
        return "Describe your experience...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.close, color: Colors.transparent),
                  const Text(
                    "Share Your Thoughts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.resetForm();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Feedback type selector
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What would you like to share?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FeedbackController.feedbackTypes.map((type) {
                    final isSelected = controller.feedbackType.value == type;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.setFeedbackType(type);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rate Your Experience",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Rating Row with GetX
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < controller.rating.value;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.setRating(index + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          isSelected
                              ? IconsPath.starIcon
                              : IconsPath.starBorder,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }),
                );
              }),

              Obx(() {
                if (controller.rating.value > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${controller.rating.value} ${controller.rating.value == 1 ? 'star' : 'stars'}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  );
                }
                return const SizedBox();
              }),

              const SizedBox(height: 20),
              Obx(() {
                return TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _getTitleHint(controller.feedbackType.value),
                    hintStyle: const TextStyle(color: Color(0xFF9A9A9E)),
                    counterStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1F),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xffF3F4F6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => controller.setTitle(value),
                );
              }),
              const SizedBox(height: 20),
              // Feedback TextField
              Obx(() {
                return TextField(
                  maxLength: 500,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _getDescriptionHint(controller.feedbackType.value),
                    hintStyle: const TextStyle(color: Color(0xFF9A9A9E)),
                    counterStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1F),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xffF3F4F6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => controller.setDescription(value),
                );
              }),

              const SizedBox(height: 20),

              // Submit Button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final success = await controller.submitRating();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
