import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String title;
  final String author;
  final String description;

  const ExpandableText({
    super.key,
    required this.title,
    required this.author,
    required this.description,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String displayText = widget.description;

    if (!_isExpanded && widget.description.length > 120) {
      displayText = "${widget.description.substring(0, 120)}...";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "By ${widget.author}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // expandable description
        Text(
          displayText,
          style: const TextStyle(
            color: Color(0xFF9A9A9E),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),

        // show more / less
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? "Show less" : "Show more",
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text(
          "By ${widget.author}",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
