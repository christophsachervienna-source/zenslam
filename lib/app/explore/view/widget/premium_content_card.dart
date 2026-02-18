import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/app/explore/model/explore_item.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/utils/content_lock_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Premium glassmorphism content card with gold accents
class PremiumContentCard extends StatefulWidget {
  final ExploreItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final double width;
  final double height;
  final bool showFavorite;
  final bool compact;

  const PremiumContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoritePressed,
    this.width = 180,
    this.height = 220,
    this.showFavorite = true,
    this.compact = false,
  });

  @override
  State<PremiumContentCard> createState() => _PremiumContentCardState();
}

class _PremiumContentCardState extends State<PremiumContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  /// Format duration to user-friendly format (e.g., "5 min", "1 hr 20 min")
  String _formatDuration(String duration) {
    final parts = duration.split(':');
    if (parts.isEmpty) return duration;

    try {
      if (parts.length == 2) {
        // MM:SS format
        final minutes = int.tryParse(parts[0]) ?? 0;
        if (minutes == 0) return '< 1 min';
        if (minutes < 60) return '$minutes min';
        final hours = minutes ~/ 60;
        final remainingMins = minutes % 60;
        if (remainingMins == 0) return '$hours hr';
        return '$hours hr $remainingMins min';
      } else if (parts.length == 3) {
        // HH:MM:SS format
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        if (hours == 0 && minutes == 0) return '< 1 min';
        if (hours == 0) return '$minutes min';
        if (minutes == 0) return '$hours hr';
        return '$hours hr $minutes min';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return duration;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primaryColor.withValues(alpha: 0.5)
                  : AppColors.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                _buildBackgroundImage(),

                // Gradient overlay
                _buildGradientOverlay(),

                // Glass effect overlay
                _buildGlassEffect(),

                // Content
                _buildContent(),

                // Favorite button
                if (widget.showFavorite) _buildFavoriteButton(),

                // Lock icon for premium (uses centralized lock logic)
                if (ContentLockHelper.instance.shouldShowLockIcon(isPaidContent: widget.item.isLocked)) _buildLockIcon(),

                // Play button
                _buildPlayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return CachedNetworkImage(
      imageUrl: widget.item.thumbnail,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          gradient: QuestionnaireTheme.cardGradient(),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          gradient: QuestionnaireTheme.cardGradient(),
        ),
        child: Icon(
          Icons.music_note,
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildGlassEffect() {
    // Create a smooth gradient blur that fades out upwards
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: widget.compact ? 80 : 110,
      child: Stack(
        children: [
          // Gradient mask for smooth blur fade
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0A0A0C).withValues(alpha: 0.4),
                  const Color(0xFF0A0A0C).withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final formattedDuration = _formatDuration(widget.item.duration);

    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with play button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Title - takes available space
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.compact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Play button
              if (!widget.compact) ...[
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.85),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Category and duration row - separate line for clarity
          Row(
            children: [
              // Category badge - full text, no truncation
              if (!widget.compact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.item.category,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!widget.compact) const SizedBox(width: 10),
              // Duration with icon
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                formattedDuration,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 12,
      left: 12,
      child: GestureDetector(
        onTap: widget.onFavoritePressed,
        child: Obx(() => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            boxShadow: widget.item.isFavorite.value
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.item.isFavorite.value
                ? Icons.favorite
                : Icons.favorite_border,
            size: 18,
            color: widget.item.isFavorite.value
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.8),
          ),
        )),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock,
          size: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // Play button is now integrated into _buildContent for better layout
  Widget _buildPlayButton() {
    return const SizedBox.shrink();
  }
}

/// Compact card variant for recently played section
class CompactContentCard extends StatelessWidget {
  final ExploreItem item;
  final VoidCallback? onTap;
  final double width;

  const CompactContentCard({
    super.key,
    required this.item,
    this.onTap,
    this.width = 140,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumContentCard(
      item: item,
      onTap: onTap,
      width: width,
      height: 160,
      showFavorite: false,
      compact: true,
    );
  }
}
