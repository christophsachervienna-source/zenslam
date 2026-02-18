import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/questionnaire_theme.dart';
import '../../widgets/premium_button.dart';
import 'forging_screen.dart';

/// Screen 6: "The Draw" (NEW)
/// Purpose: Create psychological commitment through action
/// Visual: Dark canvas with gold outline prompt
/// Copy: "Let your intention flow"
class CommitmentRitualScreen extends StatefulWidget {
  const CommitmentRitualScreen({super.key});

  @override
  State<CommitmentRitualScreen> createState() => _CommitmentRitualScreenState();
}

class _CommitmentRitualScreenState extends State<CommitmentRitualScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _buttonRevealController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonFade;

  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasDrawn = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _buttonRevealController = AnimationController(
      duration: const Duration(milliseconds: 500),
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

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonRevealController,
        curve: Curves.easeOut,
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _buttonRevealController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke = List.from(_currentStroke)..add(details.localPosition);
    });

    // Trigger button reveal when user has drawn something meaningful
    if (!_hasDrawn && _currentStroke.length > 20) {
      _hasDrawn = true;
      _showButton = true;
      _buttonRevealController.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke.isNotEmpty) {
      setState(() {
        _strokes.add(List.from(_currentStroke));
        _currentStroke = [];
      });
    }
  }

  void _clearCanvas() {
    HapticFeedback.lightImpact();
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasDrawn = false;
      _showButton = false;
    });
    _buttonRevealController.reset();
  }

  Future<void> _handleContinue() async {
    HapticFeedback.heavyImpact();

    // Save commitment ritual completion
    await SharedPrefHelper.saveCommitmentRitualCompleted(true);

    Get.to(
      () => const ForgingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    Get.to(
      () => const ForgingScreen(),
      transition: Transition.rightToLeft,
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
              animation: Listenable.merge([_entryController, _buttonRevealController]),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: QuestionnaireTheme.paddingHorizontal,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // Headline
                                _buildHeadline(),

                                const SizedBox(height: 24),

                                // Drawing canvas
                                Expanded(child: _buildDrawingCanvas()),

                                const SizedBox(height: 16),

                                // Prompt text
                                _buildPromptText(),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom button (revealed after drawing)
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

          // Progress indicator (8 steps, currently on step 5)
          _buildProgress(currentStep: 4, totalSteps: 8),

          const Spacer(),

          // Skip / Clear button
          _strokes.isNotEmpty
              ? GestureDetector(
                  onTap: _clearCanvas,
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
                      Icons.refresh_rounded,
                      color: QuestionnaireTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _handleSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: QuestionnaireTheme.backgroundSecondary.withValues(alpha: 0.6),
                      border: Border.all(
                        color: QuestionnaireTheme.borderDefault.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: QuestionnaireTheme.bodySmall(
                        color: QuestionnaireTheme.textTertiary,
                      ),
                    ),
                  ),
                ),
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

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let your intention\nflow",
          style: QuestionnaireTheme.displayMedium(),
        ),
        const SizedBox(height: 8),
        Text(
          "Draw a symbol that represents your goal",
          style: QuestionnaireTheme.bodyLarge(
            color: QuestionnaireTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawingCanvas() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusXL),
        color: QuestionnaireTheme.cardBackground,
        border: Border.all(
          color: _hasDrawn
              ? QuestionnaireTheme.accentGold.withValues(alpha: 0.4)
              : QuestionnaireTheme.borderDefault.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: _hasDrawn
            ? [
                BoxShadow(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(QuestionnaireTheme.radiusXL - 2),
        child: Stack(
          children: [
            // Grid pattern background
            CustomPaint(
              painter: _GridPatternPainter(),
              size: Size.infinite,
            ),

            // Drawing canvas
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _DrawingPainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                ),
                size: Size.infinite,
              ),
            ),

            // Placeholder text when empty
            if (_strokes.isEmpty && _currentStroke.isEmpty)
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gesture_rounded,
                        size: 48,
                        color: QuestionnaireTheme.textTertiary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Draw here',
                        style: QuestionnaireTheme.bodyMedium(
                          color: QuestionnaireTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showButton
          ? Container(
              key: const ValueKey('committed'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: QuestionnaireTheme.accentGold.withValues(alpha: 0.1),
                border: Border.all(
                  color: QuestionnaireTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: QuestionnaireTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your mark has been made',
                    style: QuestionnaireTheme.bodyMedium(
                      color: QuestionnaireTheme.accentGold,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              key: const ValueKey('prompt'),
              child: Text(
                'Ready to commit? Draw your mark.',
                textAlign: TextAlign.center,
                style: QuestionnaireTheme.bodyMedium(
                  color: QuestionnaireTheme.textTertiary,
                ),
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
      child: AnimatedOpacity(
        opacity: _showButton ? _buttonFade.value : 0.3,
        duration: const Duration(milliseconds: 200),
        child: PremiumButton(
          title: 'I Commit To My Growth',
          onTap: _showButton ? _handleContinue : null,
        ),
      ),
    );
  }
}

/// Painter for the grid pattern background
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QuestionnaireTheme.borderDefault.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for drawing strokes
class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _DrawingPainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gold gradient paint for strokes
    final paint = Paint()
      ..color = QuestionnaireTheme.accentGold
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Glow paint
    final glowPaint = Paint()
      ..color = QuestionnaireTheme.accentGold.withValues(alpha: 0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Draw all completed strokes
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      // Draw glow first
      canvas.drawPath(path, glowPaint);
      // Draw main stroke
      canvas.drawPath(path, paint);
    }

    // Draw current stroke
    if (currentStroke.length >= 2) {
      final path = Path()..moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) =>
      strokes != oldDelegate.strokes || currentStroke != oldDelegate.currentStroke;
}
