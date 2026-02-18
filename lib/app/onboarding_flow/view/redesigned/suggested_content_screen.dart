import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';

/// Premium suggested content screen
/// Shows personalized meditation recommendations
class SuggestedContentScreen extends StatefulWidget {
  const SuggestedContentScreen({super.key});

  @override
  State<SuggestedContentScreen> createState() => _SuggestedContentScreenState();
}

class _SuggestedContentScreenState extends State<SuggestedContentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: QuestionnaireTheme.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: QuestionnaireTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: QuestionnaireTheme.paddingHorizontal,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),

                              // Title section
                              _buildTitleSection(),

                              const SizedBox(height: 24),

                              // Meditation grid
                              _buildMeditationGrid(),

                              const SizedBox(height: 32),

                              // Value proposition
                              _buildValueProposition(),

                              const SizedBox(height: 32),

                              // Continue button
                              PremiumButton(
                                title: 'Unlock Full Access',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Get.to(
                                    () => const SubscriptionScreenV2(),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 350),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal - 8,
        12,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: QuestionnaireTheme.backgroundSecondary.withValues(alpha:0.6),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha:0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: QuestionnaireTheme.textPrimary,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          // Skip button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => const SubscriptionScreenV2(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Text(
              'Skip',
              style: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personalized badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: QuestionnaireTheme.accentGold.withValues(alpha:0.12),
            border: Border.all(
              color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: QuestionnaireTheme.accentGold,
              ),
              const SizedBox(width: 6),
              Text(
                'Personalized for you',
                style: QuestionnaireTheme.bodySmall(
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Meditations\nPicked for You',
          style: QuestionnaireTheme.displayMedium(),
        ),

        const SizedBox(height: 8),

        Text(
          'Based on your answers, we recommend starting with these',
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationGrid() {
    return GetBuilder<MostPopularController>(
      init: Get.find<MostPopularController>(),
      builder: (controller) {
        if (controller.isLoading.value) {
          return SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: QuestionnaireTheme.accentGold,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final items = controller.popularItems.take(4).toList();

        if (items.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Loading meditations...',
                style: QuestionnaireTheme.bodyMedium(
                  color: QuestionnaireTheme.textTertiary,
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildMeditationCard(
              title: item.title,
              duration: item.duration,
              imageUrl: item.thumbnail,
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildMeditationCard({
    required String title,
    required String duration,
    required String imageUrl,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha:0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(QuestionnaireTheme.radiusLG),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: QuestionnaireTheme.backgroundSecondary,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: QuestionnaireTheme.backgroundSecondary,
                          child: Icon(
                            Icons.self_improvement_rounded,
                            color: QuestionnaireTheme.textTertiary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha:0.7),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: QuestionnaireTheme.bodyMedium(
                              color: QuestionnaireTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: QuestionnaireTheme.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                duration,
                                style: QuestionnaireTheme.bodySmall(
                                  color: QuestionnaireTheme.accentGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Play indicator
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuestionnaireTheme.accentGold.withValues(alpha:0.9),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: QuestionnaireTheme.backgroundPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueProposition() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            QuestionnaireTheme.accentGold.withValues(alpha:0.15),
            QuestionnaireTheme.accentGold.withValues(alpha:0.05),
          ],
        ),
        border: Border.all(
          color: QuestionnaireTheme.accentGold.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.accentGold.withValues(alpha:0.2),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: QuestionnaireTheme.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock 100+ Meditations',
                      style: QuestionnaireTheme.titleMedium(
                        color: QuestionnaireTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Start your 14-day free trial',
                      style: QuestionnaireTheme.bodySmall(
                        color: QuestionnaireTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildValueItem(Icons.download_rounded, 'Offline'),
              _buildValueItem(Icons.block_rounded, 'Ad-free'),
              _buildValueItem(Icons.add_circle_outline_rounded, 'New weekly'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: QuestionnaireTheme.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: QuestionnaireTheme.bodySmall(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
