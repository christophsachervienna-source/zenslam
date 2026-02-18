import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'breathing_screen.dart';

/// Screen 5: "The Naming"
/// Purpose: Create personal connection, show "Aha Moment"
/// Visual: Clean input with animated plan reveal
/// Copy: "What should we call you?"
class NamingScreen extends StatefulWidget {
  const NamingScreen({super.key});

  @override
  State<NamingScreen> createState() => _NamingScreenState();
}

class _NamingScreenState extends State<NamingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _revealController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _revealFade;
  late Animation<double> _revealSlide;

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  String _userName = '';
  String? _challenge;
  bool _showPlanReveal = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadChallenge();

    _nameController.addListener(_onNameChanged);
  }

  Future<void> _loadChallenge() async {
    _challenge = await SharedPrefHelper.getOnboardingChallenge();
    setState(() {});
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _revealFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOut,
      ),
    );

    _revealSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entryController.forward();
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    setState(() {
      _userName = name;
    });

    if (name.length >= 2 && !_showPlanReveal) {
      setState(() {
        _showPlanReveal = true;
      });
      _revealController.forward();
      HapticFeedback.mediumImpact();
      // Don't unfocus — let the user finish typing their full name.
      // The plan reveal animates in below the text field.
    } else if (name.length < 2 && _showPlanReveal) {
      _revealController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showPlanReveal = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _revealController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
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
        return 'Deep Focus';
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

  String _getStatPercentage() {
    switch (_challenge) {
      case 'stress':
        return '47% less stressed';
      case 'sleep':
        return '52% better sleep';
      case 'focus':
        return '41% more focused';
      case 'confidence':
        return '38% more confident';
      case 'purpose':
        return '45% more clarity';
      case 'anger':
        return '43% calmer';
      default:
        return '40% improvement';
    }
  }

  Future<void> _handleContinue() async {
    if (_userName.length < 2) return;

    HapticFeedback.mediumImpact();
    _nameFocusNode.unfocus();

    // Save the name
    await SharedPrefHelper.saveOnboardingName(_userName);

    Get.to(
      () => const BreathingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => _nameFocusNode.unfocus(),
        child: Scaffold(
          backgroundColor: QuestionnaireTheme.backgroundPrimary,
          body: Container(
            decoration: const BoxDecoration(
              gradient: QuestionnaireTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entryController, _revealController]),
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with progress
                      _buildHeader(),

                      // Content
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: QuestionnaireTheme.paddingHorizontal,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),

                                  // Question headline
                                  _buildHeadline(),

                                  const SizedBox(height: 32),

                                  // Name input field
                                  _buildNameInput(),

                                  const SizedBox(height: 32),

                                  // Plan reveal (animated)
                                  if (_showPlanReveal) _buildPlanReveal(),

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom button
                      _buildBottomArea(),
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
                color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
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

          // Progress indicator (8 steps, currently on step 4)
          _buildProgress(currentStep: 3, totalSteps: 8),

          const Spacer(),

          const SizedBox(width: 44),
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
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive || isCompleted
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What should\nwe call you?",
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's make this journey personal",
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        gradient: QuestionnaireTheme.cardGradient(),
        border: Border.all(
          color: _nameFocusNode.hasFocus
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.6)
              : QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
          width: _nameFocusNode.hasFocus ? 1.5 : 1,
        ),
        boxShadow: _nameFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        style: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: QuestionnaireTheme.textPrimary,
        ),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'Your first name',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: QuestionnaireTheme.textTertiary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.person_outline_rounded,
              color: _nameFocusNode.hasFocus
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.textTertiary,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
        ),
        onTap: () => setState(() {}),
        onEditingComplete: () => _nameFocusNode.unfocus(),
      ),
    );
  }

  Widget _buildPlanReveal() {
    return Transform.translate(
      offset: Offset(0, _revealSlide.value),
      child: Opacity(
        opacity: _revealFade.value.clamp(0.0, 1.0),
        child: Column(
          children: [
            // Plan ready card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
                    QuestionnaireTheme.accentGold.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                      border: Border.all(
                        color: QuestionnaireTheme.accentGold.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'M',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: QuestionnaireTheme.accentGold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your plan is ready, $_userName!',
                          style: QuestionnaireTheme.titleMedium(
                            color: QuestionnaireTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _getChallengeEmoji(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_getChallengeLabel()} Path',
                              style: QuestionnaireTheme.bodySmall(
                                color: QuestionnaireTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                gradient: QuestionnaireTheme.cardGradient(),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: QuestionnaireTheme.accentGold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Based on similar men',
                        style: QuestionnaireTheme.bodySmall(
                          color: QuestionnaireTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Men report feeling\n',
                          style: QuestionnaireTheme.bodyLarge(
                            color: QuestionnaireTheme.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: _getStatPercentage(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: QuestionnaireTheme.accentGold,
                          ),
                        ),
                        TextSpan(
                          text: '\nin just ',
                          style: QuestionnaireTheme.bodyLarge(
                            color: QuestionnaireTheme.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: '2 weeks',
                          style: QuestionnaireTheme.bodyLarge(
                            color: QuestionnaireTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        QuestionnaireTheme.paddingHorizontal,
        16,
        QuestionnaireTheme.paddingHorizontal,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0),
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.9),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: PremiumButton(
        title: 'Continue',
        onTap: _userName.length >= 2 ? _handleContinue : null,
      ),
    );
  }
}
