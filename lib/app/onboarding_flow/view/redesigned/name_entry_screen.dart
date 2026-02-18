import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/questionnaire_scaffold.dart';
import 'personal_welcome_screen.dart';

/// Redesigned name entry screen
/// Question 3 of onboarding questionnaire
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _labelAnimation;

  bool _hasText = false;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _nameController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _nameController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
        _errorText = null; // Clear error when typing
      });
      if (hasText || _isFocused) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus || _hasText) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  Future<void> _handleContinue() async {
    final error = _validateName(_nameController.text);
    if (error != null) {
      setState(() => _errorText = error);
      HapticFeedback.mediumImpact();
      return;
    }

    final name = _nameController.text.trim();

    // Save name
    await SharedPrefHelper.saveUserName(name);
    await SharedPrefHelper.saveOnboardingName(name);

    // Update ProfileController if registered
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fullName.value = name;
    }

    debugPrint('✅ Saved onboarding name: $name');

    // Navigate to welcome screen
    Get.to(
      () => PersonalWelcomeScreen(userName: name),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuestionnaireScaffold(
      currentStep: 3,
      totalSteps: 4,
      title: "What should we\ncall you?",
      subtitle: "We'll use this to personalize your experience",
      buttonTitle: 'Continue',
      onContinue: _hasText ? _handleContinue : null,
      onBack: () => Get.back(),
      showBackButton: true,
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Name input field
          AnimatedBuilder(
            animation: _labelAnimation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating label
                  AnimatedOpacity(
                    duration: QuestionnaireTheme.animationFast,
                    opacity: (_hasText || _isFocused) ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'YOUR NAME',
                        style: QuestionnaireTheme.caption(
                          color: _isFocused
                              ? QuestionnaireTheme.accentGold
                              : QuestionnaireTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),

                  // Input container
                  AnimatedContainer(
                    duration: QuestionnaireTheme.animationMedium,
                    curve: QuestionnaireTheme.animationCurve,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(QuestionnaireTheme.radiusLG),
                      color: QuestionnaireTheme.cardBackground,
                      border: Border.all(
                        color: _errorText != null
                            ? QuestionnaireTheme.error.withValues(alpha: 0.6)
                            : _isFocused
                                ? QuestionnaireTheme.accentGold.withValues(alpha: 0.6)
                                : QuestionnaireTheme.borderDefault
                                    .withValues(alpha:0.5),
                        width: _isFocused ? 1.5 : 1.0,
                      ),
                      boxShadow: _isFocused
                          ? [
                              BoxShadow(
                                color: (_errorText != null
                                        ? QuestionnaireTheme.error
                                        : QuestionnaireTheme.accentGold)
                                    .withValues(alpha: 0.1),
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
                      onSubmitted: (_) => _handleContinue(),
                      cursorColor: QuestionnaireTheme.accentGold,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
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
                  ),

                  // Error message
                  AnimatedContainer(
                    duration: QuestionnaireTheme.animationMedium,
                    height: _errorText != null ? 32 : 0,
                    child: AnimatedOpacity(
                      duration: QuestionnaireTheme.animationFast,
                      opacity: _errorText != null ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: QuestionnaireTheme.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _errorText ?? '',
                              style: QuestionnaireTheme.bodySmall(
                                color: QuestionnaireTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusMD),
              color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.5),
              border: Border.all(
                color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(QuestionnaireTheme.radiusSM),
                    color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: QuestionnaireTheme.accentGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your privacy matters',
                        style: QuestionnaireTheme.bodyMedium(
                          color: QuestionnaireTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This is only used for personalization',
                        style: QuestionnaireTheme.bodySmall(
                          color: QuestionnaireTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Extra space for keyboard
          const SizedBox(height: 50),
        ],
        ),
      ),
    );
  }
}
