import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final double scale;
  final bool value;

  const CustomSwitch({
    super.key,
    this.onChanged,
    this.scale = 0.8,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      alignment: Alignment.topRight,
      scale: scale,
      child: SizedBox(
        height: 20,
        child: Switch(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xffffffff),
          activeTrackColor: AppColors.primaryColor,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
