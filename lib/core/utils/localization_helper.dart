import 'package:easy_localization/easy_localization.dart';

/// Helper class for localization utilities
///
/// Usage examples:
/// ```dart
/// // Simple translation
/// Text('common.loading'.tr())
///
/// // Translation with parameters
/// Text('subscription.save_percent'.tr(namedArgs: {'percent': '50'}))
///
/// // Using the helper methods
/// Text(LocalizationHelper.getGreeting())
/// ```
class LocalizationHelper {
  // Common keys
  static String get loading => 'common.loading'.tr();
  static String get error => 'common.error'.tr();
  static String get retry => 'common.retry'.tr();
  static String get cancel => 'common.cancel'.tr();
  static String get confirm => 'common.confirm'.tr();
  static String get save => 'common.save'.tr();
  static String get delete => 'common.delete'.tr();
  static String get edit => 'common.edit'.tr();
  static String get done => 'common.done'.tr();
  static String get next => 'common.next'.tr();
  static String get back => 'common.back'.tr();
  static String get skip => 'common.skip'.tr();
  static String get continueText => 'common.continue'.tr();
  static String get submit => 'common.submit'.tr();
  static String get ok => 'common.ok'.tr();
  static String get yes => 'common.yes'.tr();
  static String get no => 'common.no'.tr();
  static String get search => 'common.search'.tr();
  static String get seeAll => 'common.see_all'.tr();
  static String get noData => 'common.no_data'.tr();
  static String get somethingWentWrong => 'common.something_went_wrong'.tr();
  static String get noInternet => 'common.no_internet'.tr();
  static String get tryAgain => 'common.try_again'.tr();

  // Navigation keys
  static String get navHome => 'navigation.home'.tr();
  static String get navExplore => 'navigation.explore'.tr();
  static String get navCoach => 'navigation.coach'.tr();
  static String get navFavorite => 'navigation.favorite'.tr();
  static String get navProfile => 'navigation.profile'.tr();

  // Auth keys
  static String get welcomeBack => 'auth.welcome_back'.tr();
  static String get login => 'auth.login'.tr();
  static String get signUp => 'auth.sign_up'.tr();
  static String get signIn => 'auth.sign_in'.tr();
  static String get logout => 'auth.logout'.tr();
  static String get email => 'auth.email'.tr();
  static String get emailAddress => 'auth.email_address'.tr();
  static String get password => 'auth.password'.tr();
  static String get forgotPassword => 'auth.forgot_password'.tr();

  // Profile keys
  static String get profile => 'profile.profile'.tr();
  static String get noName => 'profile.no_name'.tr();
  static String get accountInformation => 'profile.account_information'.tr();
  static String get editProfile => 'profile.edit_profile'.tr();
  static String get settings => 'profile.settings'.tr();
  static String get preferences => 'profile.preferences'.tr();
  static String get notifications => 'profile.notifications'.tr();
  static String get privacyPolicy => 'profile.privacy_policy'.tr();
  static String get termsOfService => 'profile.terms_of_service'.tr();
  static String get youArePremium => 'profile.you_are_premium'.tr();

  // Subscription keys
  static String get transformYourMind => 'subscription.transform_your_mind'.tr();
  static String get freeTrial => 'subscription.free_trial'.tr(namedArgs: {'days': '14'});
  static String get startFreeTrial => 'subscription.start_free_trial'.tr();
  static String get unlockEverything => 'subscription.unlock_everything'.tr();
  static String get cancelAnytime => 'subscription.cancel_anytime'.tr();
  static String get restorePurchase => 'subscription.restore_purchase'.tr();
  static String get monthly => 'subscription.monthly'.tr();
  static String get yearly => 'subscription.yearly'.tr();
  static String get lifetime => 'subscription.lifetime'.tr();
  static String get tryRiskFree => 'subscription.try_risk_free'.tr();
  static String get getLifetimeAccess => 'subscription.get_lifetime_access'.tr();

  /// Returns free trial banner text with days parameter
  static String getFreeTrialBanner(int days) {
    return 'subscription.free_trial_banner'.tr(namedArgs: {'days': days.toString()});
  }

  /// Returns "Start X-Day Free Trial" text with days parameter
  static String getStartFreeTrialDays(int days) {
    return 'subscription.start_free_trial_days'.tr(namedArgs: {'days': days.toString()});
  }

  // Home keys
  static String get recommendationsForYou => 'home.recommendations_for_you'.tr();
  static String get todaysDailies => 'home.todays_dailies'.tr();
  static String get featured => 'home.featured'.tr();
  static String get series => 'home.series'.tr();
  static String get mostPopular => 'home.most_popular'.tr();
  static String get exploreAll => 'home.explore_all'.tr();
  static String get masterclasses => 'home.masterclasses'.tr();
  static String get feedbackTitle => 'home.feedback_title'.tr();
  static String get feedbackSubtitle => 'home.feedback_subtitle'.tr();
  static String get shareFeedback => 'home.share_feedback'.tr();

  // Explore categories
  static String get meditation => 'explore.meditation'.tr();
  static String get fitness => 'explore.fitness'.tr();
  static String get confidence => 'explore.confidence'.tr();
  static String get purpose => 'explore.purpose'.tr();
  static String get focus => 'explore.focus'.tr();
  static String get discipline => 'explore.discipline'.tr();
  static String get friendship => 'explore.friendship'.tr();
  static String get dating => 'explore.dating'.tr();
  static String get others => 'explore.others'.tr();
  static String get manhood => 'explore.manhood'.tr();
  static String get relationship => 'explore.relationship'.tr();

  // Error keys
  static String get failedToLoad => 'errors.failed_to_load'.tr();
  static String get failedToPlay => 'errors.failed_to_play'.tr();
  static String get checkInternet => 'errors.check_internet'.tr();
  static String get sessionExpired => 'errors.session_expired'.tr();
  static String get unauthorized => 'errors.unauthorized'.tr();

  /// Returns the appropriate greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'home.greeting_morning'.tr();
    } else if (hour < 17) {
      return 'home.greeting_afternoon'.tr();
    } else {
      return 'home.greeting_evening'.tr();
    }
  }

  /// Returns save percentage text with parameter
  static String getSavePercent(String percent) {
    return 'subscription.save_percent'.tr(namedArgs: {'percent': percent});
  }

  /// Returns minutes remaining text with parameter
  static String getMinutesRemaining(int minutes) {
    return 'player.minutes_remaining'.tr(namedArgs: {'minutes': minutes.toString()});
  }

  /// Returns "then price per period" text with parameters
  static String getThenPricePerPeriod(String price, String period) {
    return 'subscription.then_price_per_period'.tr(
      namedArgs: {'price': price, 'period': period},
    );
  }
}
