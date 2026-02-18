import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'goals_screen.dart';

/// Personal welcome screen after name entry
/// Creates a moment of connection before final question
class PersonalWelcomeScreen extends StatefulWidget {
  final String userName;

  const PersonalWelcomeScreen({
    super.key,
    required this.userName,
  });

  @override
  State<PersonalWelcomeScreen> createState() => _PersonalWelcomeScreenState();
}

class _PersonalWelcomeScreenState extends State<PersonalWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _nameSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Staggered animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _nameSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
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
                animation: Listenable.merge([_mainController, _glowController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      const Spacer(flex: 2),

                      // Animated glow circle
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  QuestionnaireTheme.accentGold.withValues(
                                    alpha: 0.15 * _glowAnimation.value,
                                  ),
                                  QuestionnaireTheme.accentGold.withValues(
                                    alpha: 0.05 * _glowAnimation.value,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: QuestionnaireTheme.cardBackground,
                                  border: Border.all(
                                    color: QuestionnaireTheme.accentGold
                                        .withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: QuestionnaireTheme.accentGold
                                          .withValues(
                                        alpha: 0.2 * _glowAnimation.value,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(widget.userName),
                                    style:
                                        QuestionnaireTheme.displayLarge(
                                          color: QuestionnaireTheme.accentGold,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Welcome text
                      Transform.translate(
                        offset: Offset(0, _nameSlideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            'Welcome,',
                            style: QuestionnaireTheme.headline(
                              color: QuestionnaireTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Name with golden accent
                      Transform.translate(
                        offset: Offset(0, _nameSlideAnimation.value * 0.5),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  QuestionnaireTheme.accentGoldLight,
                                  QuestionnaireTheme.accentGold,
                                  QuestionnaireTheme.accentGoldDark,
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              widget.userName,
                              style: QuestionnaireTheme.displayLarge(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Subtitle
                      Opacity(
                        opacity: _subtitleFadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'This is your space to recharge,\nrefocus, and grow stronger.',
                            style: QuestionnaireTheme.bodyLarge(
                              color: QuestionnaireTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Motivational quote
                      Opacity(
                        opacity: _subtitleFadeAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              QuestionnaireTheme.radiusLG,
                            ),
                            color: QuestionnaireTheme.backgroundSecondary
                                .withValues(alpha: 0.5),
                            border: Border.all(
                              color: QuestionnaireTheme.borderDefault
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: QuestionnaireTheme.accentGold
                                    .withValues(alpha: 0.5),
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"The greatest glory in living lies not in never falling, but in rising every time we fall."',
                                style: QuestionnaireTheme.bodyMedium(
                                  color: QuestionnaireTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '— Nelson Mandela',
                                style: QuestionnaireTheme.caption(
                                  color: QuestionnaireTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Continue button
                      Opacity(
                        opacity: _buttonFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _buttonFadeAnimation.value),
                          ),
                          child: PremiumButton(
                            title: "Let's Begin",
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Get.to(
                                () => GoalsScreen(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 350),
                              );
                            },
                          ),
                        ),
                      ),

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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
