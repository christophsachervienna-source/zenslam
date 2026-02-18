import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'suggested_content_screen.dart';

/// Premium brand showcase screen
/// Displays Zenslam values and builds anticipation
class BrandShowcaseScreen extends StatefulWidget {
  const BrandShowcaseScreen({super.key});

  @override
  State<BrandShowcaseScreen> createState() => _BrandShowcaseScreenState();
}

class _BrandShowcaseScreenState extends State<BrandShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _badgeController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _titleSlide;
  late Animation<double> _badge1Animation;
  late Animation<double> _badge2Animation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _badge1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _badge2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _badgeController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _badgeController.dispose();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: QuestionnaireTheme.paddingHorizontal,
              ),
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([_entryController, _badgeController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo and brand name
                      _buildBrandHeader(),

                      const SizedBox(height: 48),

                      // Trust badges
                      _buildTrustBadges(),

                      const Spacer(flex: 2),

                      // Features list
                      _buildFeaturesList(),

                      const Spacer(flex: 1),

                      // Continue button
                      _buildContinueButton(),

                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 24,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Logo circle
        Transform.translate(
          offset: Offset(0, _titleSlide.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        QuestionnaireTheme.accentGoldLight,
                        QuestionnaireTheme.accentGold,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'M',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Brand name
        Transform.translate(
          offset: Offset(0, _titleSlide.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              'ZENSLAM',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
                color: QuestionnaireTheme.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tagline
        Transform.translate(
          offset: Offset(0, _titleSlide.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              'The Meditation App for Men',
              style: QuestionnaireTheme.bodyLarge(
                color: QuestionnaireTheme.accentGold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Expert badge
        Transform.scale(
          scale: _badge1Animation.value,
          child: Opacity(
            opacity: _badge1Animation.value,
            child: _buildBadge(
              icon: Icons.science_outlined,
              title: 'Expert',
              subtitle: 'Science-backed\nMeditation',
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Trusted badge
        Transform.scale(
          scale: _badge2Animation.value,
          child: Opacity(
            opacity: _badge2Animation.value,
            child: _buildBadge(
              icon: Icons.groups_outlined,
              title: 'Trusted',
              subtitle: 'By Men\nWorldwide',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.12),
            ),
            child: Icon(
              icon,
              color: QuestionnaireTheme.accentGold,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: QuestionnaireTheme.titleMedium(
              color: QuestionnaireTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: QuestionnaireTheme.bodySmall(
              color: QuestionnaireTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Personalized meditation journeys',
      'Expert-crafted audio sessions',
      'Track your progress over time',
    ];

    return Opacity(
      opacity: _fadeAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
          color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
          border: Border.all(
            color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: features.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < features.length - 1 ? 16 : 0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: QuestionnaireTheme.accentGold,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: QuestionnaireTheme.bodyMedium(
                        color: QuestionnaireTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Opacity(
      opacity: _buttonAnimation.value,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - _buttonAnimation.value)),
        child: PremiumButton(
          title: 'Explore Meditations',
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(
              () => const SuggestedContentScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 350),
            );
          },
        ),
      ),
    );
  }
}
