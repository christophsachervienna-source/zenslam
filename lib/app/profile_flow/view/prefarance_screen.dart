import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/challenge_selection_screen.dart';
import 'package:zenslam/app/onboarding_flow/view/optimized/time_selection_screen.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Preferences screen - aligned with the optimized onboarding flow
/// Shows the same questions users answered during onboarding
class PrefaranceScreen extends StatefulWidget {
  const PrefaranceScreen({super.key});

  @override
  State<PrefaranceScreen> createState() => _PrefaranceScreenState();
}

class _PrefaranceScreenState extends State<PrefaranceScreen> {
  // Onboarding answers
  String? _selectedChallenge;
  String? _selectedTime;
  String? _userName;
  bool _isLoading = true;
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  // Challenge options data (matching ChallengeSelectionScreen)
  final Map<String, ChallengeData> _challengeOptions = {
    'stress': ChallengeData(
      title: 'Stress & Calm',
      subtitle: 'Find calm in the chaos',
      emoji: '😤',
      color: const Color(0xFFE57373),
    ),
    'sleep': ChallengeData(
      title: 'Better Sleep',
      subtitle: 'Rest deeply, wake refreshed',
      emoji: '😴',
      color: const Color(0xFF7986CB),
    ),
    'focus': ChallengeData(
      title: 'Focus & Clarity',
      subtitle: 'Sharpen your mind',
      emoji: '🎯',
      color: const Color(0xFF4FC3F7),
    ),
    'confidence': ChallengeData(
      title: 'Build Confidence',
      subtitle: 'Unlock your potential',
      emoji: '💪',
      color: const Color(0xFFFFB74D),
    ),
    'purpose': ChallengeData(
      title: 'Finding Purpose',
      subtitle: 'Discover what drives you',
      emoji: '🧭',
      color: const Color(0xFF81C784),
    ),
    'anger': ChallengeData(
      title: 'Managing Emotions',
      subtitle: 'Stay in control',
      emoji: '🌊',
      color: const Color(0xFFBA68C8),
    ),
  };

  // Time options data (matching TimeSelectionScreen)
  final Map<String, TimeData> _timeOptions = {
    '5min': TimeData(
      title: '5 minutes',
      subtitle: 'Quick daily reset',
      emoji: '⚡',
    ),
    '10min': TimeData(
      title: '10 minutes',
      subtitle: 'Recommended for beginners',
      emoji: '🌱',
    ),
    '15min': TimeData(
      title: '15 minutes',
      subtitle: 'Deeper practice',
      emoji: '🧘',
    ),
    '20min+': TimeData(
      title: '20+ minutes',
      subtitle: 'Full transformation',
      emoji: '🏔️',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final challenge = await SharedPrefHelper.getOnboardingChallenge();
    final time = await SharedPrefHelper.getOnboardingTime();
    final name = await SharedPrefHelper.getOnboardingName();

    if (mounted) {
      setState(() {
        _selectedChallenge = challenge;
        _selectedTime = time;
        _userName = name;
        _nameController.text = name ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      await SharedPrefHelper.saveOnboardingName(newName);
      await SharedPrefHelper.saveUserName(newName);
      setState(() {
        _userName = newName;
        _isEditingName = false;
      });
    }
  }

  Future<void> _editChallenge() async {
    final result = await Get.to(
      () => const ChallengeSelectionScreen(isFromPreference: true),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );

    if (result == true) {
      await _loadPreferences();
    }
  }

  Future<void> _editTime() async {
    final result = await Get.to(
      () => const TimeSelectionScreen(isFromPreference: true),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );

    if (result == true) {
      await _loadPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Premium header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: QuestionnaireTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Preferences',
                    style: QuestionnaireTheme.headline(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          // Info card
                          _buildInfoCard(),

                          const SizedBox(height: 24),

                          // Name section
                          _buildNameSection(),

                          const SizedBox(height: 20),

                          // Challenge section
                          _buildChallengeSection(),

                          const SizedBox(height: 20),

                          // Time section
                          _buildTimeSection(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.15),
            AppColors.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Personalization',
                  style: QuestionnaireTheme.titleMedium(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust your preferences to get better recommendations',
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'What should we call you?',
                  style: QuestionnaireTheme.titleMedium(),
                ),
              ),
              if (!_isEditingName)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditingName = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditingName)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: QuestionnaireTheme.bodyLarge(
                      color: QuestionnaireTheme.textPrimary,
                    ),
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: QuestionnaireTheme.bodyMedium(
                        color: QuestionnaireTheme.textTertiary,
                      ),
                      filled: true,
                      fillColor: QuestionnaireTheme.backgroundSecondary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: QuestionnaireTheme.borderDefault,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _saveName,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _nameController.text = _userName ?? '';
                      _isEditingName = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: QuestionnaireTheme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: QuestionnaireTheme.borderDefault,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: QuestionnaireTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          else
            _buildNameItem(),
        ],
      ),
    );
  }

  Widget _buildNameItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: QuestionnaireTheme.backgroundSecondary,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? 'Not set',
                  style: QuestionnaireTheme.titleMedium(),
                ),
                Text(
                  'Your display name',
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_userName != null && _userName!.isNotEmpty)
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.black,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeSection() {
    final challengeData = _selectedChallenge != null
        ? _challengeOptions[_selectedChallenge]
        : null;

    return _buildPreferenceCard(
      title: "What's your biggest challenge?",
      hasSelection: challengeData != null,
      onEdit: _editChallenge,
      child: challengeData != null
          ? _buildChallengeItem(challengeData)
          : _buildEmptyState('No challenge selected'),
    );
  }

  Widget _buildTimeSection() {
    final timeData = _selectedTime != null ? _timeOptions[_selectedTime] : null;

    return _buildPreferenceCard(
      title: "How much time can you commit?",
      hasSelection: timeData != null,
      onEdit: _editTime,
      child: timeData != null
          ? _buildTimeItem(timeData)
          : _buildEmptyState('No time selected'),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required bool hasSelection,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: QuestionnaireTheme.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: QuestionnaireTheme.titleMedium(),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildChallengeItem(ChallengeData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: QuestionnaireTheme.backgroundSecondary,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: QuestionnaireTheme.titleMedium(),
                ),
                Text(
                  data.subtitle,
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.black,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(TimeData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: QuestionnaireTheme.backgroundSecondary,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: QuestionnaireTheme.titleMedium(),
                ),
                Text(
                  data.subtitle,
                  style: QuestionnaireTheme.bodySmall(
                    color: QuestionnaireTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.black,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 32,
              color: QuestionnaireTheme.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: QuestionnaireTheme.bodySmall(
                color: QuestionnaireTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap edit to set your preference',
              style: QuestionnaireTheme.bodySmall(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data classes for challenge and time options
class ChallengeData {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const ChallengeData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

class TimeData {
  final String title;
  final String subtitle;
  final String emoji;

  const TimeData({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}
