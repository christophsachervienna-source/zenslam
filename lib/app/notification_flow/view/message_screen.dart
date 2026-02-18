import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/widgets/fade_in_widget.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zenslam/app/mentor_flow/controller/mentor_controller.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final Set<int> _animatedIndices = {};
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    // Fresh chat every session
    controller.messages.clear();
    _animatedIndices.clear();

    inputController.addListener(() {
      final hasText = inputController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: QuestionnaireTheme.animationMedium,
          curve: QuestionnaireTheme.animationCurve,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _sendMessage() {
    final text = inputController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      controller.sendMessage(text);
      inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final messages = controller.messages;

                if (messages.isEmpty && !controller.isThinking.value) {
                  return _buildEmptyState();
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount:
                      messages.length + (controller.isThinking.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length &&
                        controller.isThinking.value) {
                      return _buildThinkingBubble();
                    }

                    final msg = messages[index];
                    final isUser = msg["sender"] == "user";
                    final time = msg["time"] as DateTime?;

                    final bubble = _buildMessageBubble(
                      message: msg["msg"] ?? "",
                      isUser: isUser,
                      time: time,
                    );

                    // Only animate new messages
                    if (!_animatedIndices.contains(index)) {
                      _animatedIndices.add(index);
                      return SlideInWidget(
                        duration: QuestionnaireTheme.animationMedium,
                        delay: const Duration(milliseconds: 100),
                        curve: QuestionnaireTheme.animationCurve,
                        beginOffset: Offset(isUser ? 0.3 : -0.3, 0),
                        child: bubble,
                      );
                    }

                    return bubble;
                  },
                );
              }),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: QuestionnaireTheme.backgroundSecondary,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Mentor',
                  style: QuestionnaireTheme.titleMedium(),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Obx(
                      () => AnimatedSwitcher(
                        duration: QuestionnaireTheme.animationFast,
                        child: controller.isThinking.value
                            ? Text(
                                'typing...',
                                key: const ValueKey('typing'),
                                style: QuestionnaireTheme.bodySmall(
                                  color: QuestionnaireTheme.textTertiary,
                                ).copyWith(fontStyle: FontStyle.italic),
                              )
                            : Text(
                                'Online',
                                key: const ValueKey('online'),
                                style: QuestionnaireTheme.bodySmall(
                                  color: QuestionnaireTheme.textTertiary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.2),
                  AppColors.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Start a Conversation",
            style: QuestionnaireTheme.titleLarge(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Ask your AI mentor anything about mindfulness, meditation, or personal growth.",
              textAlign: TextAlign.center,
              style: QuestionnaireTheme.bodyMedium(
                color: QuestionnaireTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    const suggestions = [
      "I'm feeling stressed",
      "Help me focus",
      "I can't sleep",
      "Build discipline",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: suggestions.map((text) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.sendMessage(text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.5),
                ),
                color: AppColors.primaryColor.withValues(alpha: 0.08),
              ),
              child: Text(
                text,
                style: QuestionnaireTheme.label(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return SlideInWidget(
      duration: QuestionnaireTheme.animationMedium,
      delay: const Duration(milliseconds: 100),
      curve: QuestionnaireTheme.animationCurve,
      beginOffset: const Offset(-0.3, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBotAvatar(),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: QuestionnaireTheme.cardGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: const _TypingDots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.3),
            AppColors.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.primaryColor,
        size: 13,
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    DateTime? time,
  }) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.85),
                ],
              )
            : QuestionnaireTheme.cardGradient(),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft:
              isUser ? const Radius.circular(20) : const Radius.circular(4),
          bottomRight:
              isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
        border: isUser
            ? null
            : Border.all(
                color: QuestionnaireTheme.borderDefault,
              ),
        boxShadow: isUser
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        message,
        style: QuestionnaireTheme.bodyMedium(
          color: isUser ? Colors.black : QuestionnaireTheme.textPrimary,
        ),
      ),
    );

    final timeString = time != null ? _formatTime(time) : null;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(alignment: Alignment.centerRight, child: bubble),
            if (timeString != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(
                  timeString,
                  style: QuestionnaireTheme.caption(
                    color: QuestionnaireTheme.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Bot message with avatar
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bubble,
                if (timeString != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      timeString,
                      style: QuestionnaireTheme.caption(
                        color: QuestionnaireTheme.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: QuestionnaireTheme.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: QuestionnaireTheme.borderDefault,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: QuestionnaireTheme.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: QuestionnaireTheme.borderDefault,
                ),
              ),
              child: TextField(
                controller: inputController,
                style: QuestionnaireTheme.bodyMedium(),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  hintText: "Ask your mentor...",
                  hintStyle: QuestionnaireTheme.bodyMedium(
                    color: QuestionnaireTheme.textTertiary,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(
            onTap: _sendMessage,
            enabled: _hasText,
          ),
        ],
      ),
    );
  }
}

// --- Typing dots widget ---

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (_) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
            ),
          ),
        );
      }),
    );
  }
}

// --- Send button with press animation ---

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled;

  const _SendButton({required this.onTap, required this.enabled});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        if (widget.enabled) {
          widget.onTap();
        }
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.85),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
