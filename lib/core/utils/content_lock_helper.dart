import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';

/// Centralized helper for content lock logic.
/// Ensures consistent lock behavior across all UI components.
class ContentLockHelper {
  static ContentLockHelper? _instance;
  ContentLockHelper._();

  static ContentLockHelper get instance {
    _instance ??= ContentLockHelper._();
    return _instance!;
  }

  /// Returns true if lock icon should be shown for this content.
  ///
  /// Logic:
  /// - FREE content: Never locked
  /// - PAID content: Locked unless user has active subscription or trial
  bool shouldShowLockIcon({required bool isPaidContent}) {
    if (!isPaidContent) return false;
    return !_hasUnlockedAccess();
  }

  /// Returns true if playback should be blocked for this content.
  /// Uses the same logic as shouldShowLockIcon for consistency.
  bool shouldBlockPlayback({required bool isPaidContent}) {
    return shouldShowLockIcon(isPaidContent: isPaidContent);
  }

  /// Checks if the current user has unlocked access to premium content.
  ///
  /// Returns true if:
  /// - User is logged in AND has active subscription
  /// - User is logged in AND has active trial (isTrialExpired == false)
  bool _hasUnlockedAccess() {
    if (!Get.isRegistered<ProfileController>()) {
      debugPrint('🔒 ContentLockHelper: ProfileController not registered');
      return false;
    }

    final pc = Get.find<ProfileController>();

    // Not logged in = no access to premium content
    if (pc.fullName.value.isEmpty && pc.email.value.isEmpty) {
      debugPrint('🔒 ContentLockHelper: User not logged in');
      return false;
    }

    // Active subscription = full access
    if (pc.activeSubscription.value == true) {
      debugPrint('🔓 ContentLockHelper: User has active subscription');
      return true;
    }

    // Active trial (isTrialExpired == false) = full access
    if (pc.isTrialExpired.value == false) {
      debugPrint('🔓 ContentLockHelper: User has active trial');
      return true;
    }

    debugPrint('🔒 ContentLockHelper: User has no subscription or trial');
    return false;
  }
}
