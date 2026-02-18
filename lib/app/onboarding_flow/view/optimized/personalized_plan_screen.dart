import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'content_preview_screen.dart';

/// Personalized plan screen - the "Aha Moment"
/// This is where users see the value of the app based on their answers
/// Creates emotional connection and demonstrates personalized value
class PersonalizedPlanScreen extends StatefulWidget {
  const PersonalizedPlanScreen({super.key});

  @override
  State<PersonalizedPlanScreen> createState() => _PersonalizedPlanScreenState();
}

class _PersonalizedPlanScreenState extends State<PersonalizedPlanScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _entryController;
  late AnimationController _planRevealController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _planFadeAnimation;
  late Animation<double> _planScaleAnimation;

  bool _hasText = false;
  bool _isFocused = false;
  bool _showPlan = false;
  String? _challenge;
  String? _time;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadPreviousAnswers();
    _nameController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  Future<void> _loadPreviousAnswers() async {
    _challenge = await SharedPrefHelper.getOnboardingChallenge();
    _time = await SharedPrefHelper.getOnboardingTime();
    setState(() {});
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _planRevealController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _planFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _planRevealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _planScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _planRevealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _entryController.dispose();
    _planRevealController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _nameController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    // Auto-show plan when name is entered
    if (hasText && !_showPlan && _nameController.text.trim().length >= 2) {
      _revealPlan();
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _revealPlan() {
    setState(() => _showPlan = true);
    _planRevealController.forward();
    HapticFeedback.mediumImpact();
    _focusNode.unfocus();
  }

  Future<void> _handleContinue() async {
    if (!_hasText || _nameController.text.trim().length < 2) return;

    HapticFeedback.lightImpact();

    final name = _nameController.text.trim();

    // Save name
    await SharedPrefHelper.saveUserName(name);
    await SharedPrefHelper.saveOnboardingName(name);

    // Update ProfileController if registered
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fullName.value = name;
    }

    debugPrint('✅ Saved onboarding name: $name');

    Get.to(
      () => const ContentPreviewScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );
  }

  String _getChallengeTitle() {
    switch (_challenge) {
      case 'stress':
        return 'Stress & Calm';
      case 'sleep':
        return 'Better Sleep';
      case 'focus':
        return 'Focus & Clarity';
      case 'confidence':
        return 'Building Confidence';
      case 'purpose':
        return 'Finding Purpose';
      case 'anger':
        return 'Emotional Balance';
      default:
        return 'Personal Growth';
    }
  }

  String _getStatistic() {
    switch (_challenge) {
      case 'stress':
        return '47% less stressed';
      case 'sleep':
        return '62% better sleep';
      case 'focus':
        return '38% more productive';
      case 'confidence':
        return '52% more confident';
      case 'purpose':
        return '45% more fulfilled';
      case 'anger':
        return '56% calmer responses';
      default:
        return '40% improved wellbeing';
    }
  }

  String _getTimeframe() {
    switch (_time) {
      case '5min':
        return '3 weeks';
      case '10min':
        return '2 weeks';
      case '15min':
        return '10 days';
      case '20min+':
        return '1 week';
      default:
        return '2 weeks';
    }
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
              animation:
                  Listenable.merge([_entryController, _planRevealController]),
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: QuestionnaireTheme.paddingHorizontal,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),

                                  // Question
                                  Text(
                                    "What should we\ncall you?",
                                    style: QuestionnaireTheme.displayMedium(),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "We'll personalize your journey",
                                    style: QuestionnaireTheme.bodyLarge(
                                      color: QuestionnaireTheme.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Name input
                                  _buildNameInput(),

                                  const SizedBox(height: 24),

                                  // Personalized plan preview (reveals after name entry)
                                  if (_showPlan) _buildPersonalizedPlan(),

                                  const SizedBox(height: 100),
                                ],
                              ),
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

          // Progress
          _buildProgress(),

          const Spacer(),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index == 2;
        final isCompleted = index < 2;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive || isCompleted
                  ? QuestionnaireTheme.accentGold
                  : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNameInput() {
    return AnimatedContainer(
      duration: QuestionnaireTheme.animationMedium,
      curve: QuestionnaireTheme.animationCurve,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: _isFocused
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.6)
              : QuestionnaireTheme.borderDefault.withValues(alpha: 0.5),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _focusNode,
        style: QuestionnaireTheme.titleLarge(
          color: QuestionnaireTheme.textPrimary,
        ),
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (_hasText) _revealPlan();
        },
        cursorColor: QuestionnaireTheme.accentGold,
        decoration: InputDecoration(
          hintText: 'Enter your first name',
          hintStyle: QuestionnaireTheme.titleLarge(
            color: QuestionnaireTheme.textTertiary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: InputBorder.none,
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: () {
                    _nameController.clear();
                    setState(() => _showPlan = false);
                    _planRevealController.reset();
                    HapticFeedback.lightImpact();
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: QuestionnaireTheme.textTertiary,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPersonalizedPlan() {
    final name = _nameController.text.trim();

    return Transform.scale(
      scale: _planScaleAnimation.value,
      child: Opacity(
        opacity: _planFadeAnimation.value.clamp(0.0, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuestionnaireTheme.accentGold.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: QuestionnaireTheme.titleLarge(
                              color: QuestionnaireTheme.accentGold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your plan is ready, $name!',
                              style: QuestionnaireTheme.titleMedium(
                                color: QuestionnaireTheme.textPrimary,
                              ),
                            ),
                            Text(
                              _getChallengeTitle(),
                              style: QuestionnaireTheme.bodySmall(
                                color: QuestionnaireTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Statistics card - the "Aha Moment"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                color: QuestionnaireTheme.cardBackground,
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: QuestionnaireTheme.accentGold,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Based on similar profiles',
                    style: QuestionnaireTheme.bodySmall(
                      color: QuestionnaireTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Men report feeling ',
                          style: QuestionnaireTheme.bodyLarge(
                            color: QuestionnaireTheme.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: _getStatistic(),
                          style: QuestionnaireTheme.titleLarge(
                            color: QuestionnaireTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'in just ${_getTimeframe()}',
                    style: QuestionnaireTheme.bodyMedium(
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // What you'll get
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusLG),
                color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your personalized path includes:',
                    style: QuestionnaireTheme.bodyMedium(
                      color: QuestionnaireTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPlanItem('Curated meditations for your goals'),
                  _buildPlanItem('Daily reminders to stay on track'),
                  _buildPlanItem('Progress tracking & insights'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QuestionnaireTheme.accentGold.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: QuestionnaireTheme.accentGold,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textPrimary,
              ),
            ),
          ),
        ],
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
            QuestionnaireTheme.backgroundPrimary.withValues(alpha: 0.8),
            QuestionnaireTheme.backgroundPrimary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: PremiumButton(
        title: _showPlan ? 'See My Recommendations' : 'Continue',
        onTap: _hasText && _nameController.text.trim().length >= 2
            ? _handleContinue
            : null,
      ),
    );
  }
}
