import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  Map<String, dynamic> _getGreetingData() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return {
        'greeting': 'Good Morning',
        'color': Color(0xffFFA726), // Orange for morning
      };
    } else if (hour >= 12 && hour < 17) {
      return {
        'greeting': 'Good Afternoon',
        'color': Color(0xff4FC3F7), // Blue for afternoon
      };
    } else if (hour >= 17 && hour < 21) {
      return {
        'greeting': 'Good Evening',

        'color': Color(0xff7E57C2), // Purple for evening
      };
    } else {
      return {
        'greeting': 'Good Night',

        'color': Color(0xff263238), // Dark blue for night
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingData = _getGreetingData();
    final greeting = greetingData['greeting'] as String;

    final fullText = greeting;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fullText,
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
