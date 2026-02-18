import 'package:cached_network_image/cached_network_image.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/favorite_flow/widget/nav_bar_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/subscription_screen_v2.dart';
import 'package:zenslam/app/profile_flow/controller/onboarding_preference_helper.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';

/// Screen 8: "The Gateway"
/// Purpose: Show value, convert to trial
/// Visual: Grid of personalized meditation cards (locked)
/// Copy: "Welcome, [Name]" with trial banner
class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  String _userName = '';
  String? _challenge;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
    _saveOnboardingComplete();
  }

  Future<void> _loadUserData() async {
    _userName = await SharedPrefHelper.getOnboardingName() ?? 'there';
    _challenge = await SharedPrefHelper.getOnboardingChallenge();
    setState(() {});
  }

  Future<void> _saveOnboardingComplete() async {
    // Save all preferences
    await OnboardingPreferenceHelper.saveAllPreferences();
    await SharedPrefHelper.saveIsOnboardingCompleted(true);
  }

  void _initAnimations() {
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

  String _getChallengeEmoji() {
    switch (_challenge) {
      case 'stress':
        return '😤';
      case 'sleep':
        return '😴';
      case 'focus':
        return '🎯';
      case 'confidence':
        return '💪';
      case 'purpose':
        return '🧭';
      case 'anger':
        return '🔥';
      default:
        return '✨';
    }
  }

  String _getChallengeLabel() {
    switch (_challenge) {
      case 'stress':
        return 'Stress Management';
      case 'sleep':
        return 'Better Sleep';
      case 'focus':
        return 'Focus';
      case 'confidence':
        return 'Confidence';
      case 'purpose':
        return 'Purpose';
      case 'anger':
        return 'Inner Peace';
      default:
        return 'Growth';
    }
  }

  void _handleStartTrial() {
    HapticFeedback.mediumImpact();
    Get.to(
      () => const SubscriptionScreenV2(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );
  }

  void _handleSkipTrial() async {
    HapticFeedback.lightImpact();

    // Reload profile to ensure onboarding name is loaded
    try {
      final profileController = Get.find<ProfileController>();
      await profileController.loadProfile();
    } catch (_) {
      // Controller not initialized yet, will load on home screen
    }

    Get.offAll(
      () => NavBarScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
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
                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
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
                              const SizedBox(height: 20),

                              // Title section with badge
                              _buildTitleSection(),

                              const SizedBox(height: 24),

                              // Meditation grid
                              _buildMeditationGrid(),

                              const SizedBox(height: 28),

                              // Trial banner
                              _buildTrialBanner(),

                              const SizedBox(height: 24),

                              // Primary CTA
                              PremiumButton(
                                title: 'Start 14-Day Free Trial',
                                onTap: _handleStartTrial,
                              ),

                              const SizedBox(height: 12),

                              // Secondary option
                              _buildSecondaryOption(),

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
        QuestionnaireTheme.paddingHorizontal,
        12,
        QuestionnaireTheme.paddingHorizontal,
        0,
      ),
      child: Row(
        children: [
          const Spacer(),

          // Progress (completed)
          _buildProgress(currentStep: 7, totalSteps: 8),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProgress({required int currentStep, required int totalSteps}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive || isCompleted
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personalized badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.12),
            border: Border.all(
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getChallengeEmoji(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'For ${_getChallengeLabel()}',
                style: QuestionnaireTheme.bodySmall(
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Welcome text
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Welcome, ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: QuestionnaireTheme.textPrimary,
                ),
              ),
              TextSpan(
                text: _userName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: QuestionnaireTheme.accentGold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "Your journey begins with these",
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationGrid() {
    return GetBuilder<MostPopularController>(
      init: Get.put(MostPopularController()),
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
          return _buildPlaceholderGrid();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
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

  Widget _buildPlaceholderGrid() {
    final placeholders = [
      {'title': 'Morning Calm', 'duration': '10 min'},
      {'title': 'Stress Release', 'duration': '15 min'},
      {'title': 'Deep Focus', 'duration': '12 min'},
      {'title': 'Evening Wind Down', 'duration': '20 min'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: placeholders.length,
      itemBuilder: (context, index) {
        final item = placeholders[index];
        return _buildMeditationCard(
          title: item['title']!,
          duration: item['duration']!,
          imageUrl: '',
          index: index,
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
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                child: Stack(
                  children: [
                    // Background image or placeholder
                    Positioned.fill(
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildImagePlaceholder(),
                              errorWidget: (context, url, error) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
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
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Lock overlay
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: QuestionnaireTheme.titleMedium(
                              color: QuestionnaireTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
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

                    // Lock icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(
                            color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: QuestionnaireTheme.textSecondary,
                          size: 16,
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

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
            QuestionnaireTheme.backgroundSecondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.self_improvement_rounded,
          color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
          size: 44,
        ),
      ),
    );
  }

  Widget _buildTrialBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
            QuestionnaireTheme.accentGold.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                  border: Border.all(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: QuestionnaireTheme.accentGold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Your Full Journey',
                      style: QuestionnaireTheme.titleMedium(
                        color: QuestionnaireTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '100+ meditations • Offline • No ads',
                      style: QuestionnaireTheme.bodySmall(
                        color: QuestionnaireTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureChip(Icons.check_circle_outline_rounded, 'Cancel anytime'),
              _buildFeatureChip(Icons.credit_card_off_rounded, 'No charge for 14 days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: QuestionnaireTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: QuestionnaireTheme.bodySmall(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryOption() {
    return Center(
      child: GestureDetector(
        onTap: _handleSkipTrial,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Continue with limited access',
            style: QuestionnaireTheme.bodyMedium(
              color: QuestionnaireTheme.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
