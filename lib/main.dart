import 'package:zenslam/core/route/transition_builder.dart';
import 'package:zenslam/app/explore/controller/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:zenslam/app/explore/controller/explore_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/bottom_nav_bar/controller/explore_all_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/featured_controller.dart';
import 'package:zenslam/app/bottom_nav_bar/view/home_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/master_classes_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/most_popular_controller.dart';
import 'package:zenslam/app/favorite_flow/controller/recommendation_controller.dart';
import 'package:zenslam/app/home_flow/controller/series_controller.dart';
import 'package:zenslam/app/home_flow/controller/todays_dilles_controller.dart';
import 'package:zenslam/app/onboarding_flow/controller/onboarding_controller.dart';
import 'package:zenslam/app/profile_flow/controller/profile_controller.dart';
import 'package:zenslam/app/splash/controller/app_life_cycle_controller.dart';
import 'package:zenslam/app/splash/controller/intro_audio_controller.dart';
import 'package:zenslam/app/profile_flow/controller/splash_controller.dart';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/config/env_config.dart';
import 'package:zenslam/core/config/supabase_config.dart';
import 'package:zenslam/core/services/connectivity_service.dart';
import 'package:zenslam/core/services/revenuecat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/const/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefetch fonts to avoid flash of unstyled text
  GoogleFonts.pendingFonts([
    GoogleFonts.bebasNeue(),
    GoogleFonts.outfit(),
  ]);

  // Lock app to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } else if (EnvConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  // Run critical initializations in parallel for faster startup
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    _initFirebase(),
    _setup(),
  ]);

  // Initialize ConnectivityService
  Get.put(ConnectivityService(), permanent: true);

  // Initialize AudioService in background (don't block app start)
  _initializeAudioService();

  // Wrap app in Sentry for crash reporting
  if (EnvConfig.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = EnvConfig.sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = EnvConfig.environment;
      },
      appRunner: () => _runApp(),
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

Future<void> _initFirebase() async {
  try {
    // Firebase is still needed for push notifications (FCM)
    await Firebase.initializeApp();
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      debugPrint('Firebase init error (non-critical): $e');
    }
  }
}

Future<void> _setup() async {
  final rc = Get.put(RevenueCatService(), permanent: true);
  await rc.initialize();
}

Future<void> _initializeAudioService() async {
  debugPrint('Starting AudioService initialization in main()...');
  try {
    final audioService = Get.put(AudioService(), permanent: true);
    await audioService.init();
    debugPrint('AudioService initialization completed in main()');
  } catch (e) {
    debugPrint('Failed to initialize AudioService in main(): $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      // Localization configuration
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      initialBinding: AppBindings(),
      // Use custom transition for all GetX routes to prevent white flash
      customTransition: GlobalDarkTransition(),
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryColor,
          secondary: AppColors.accentYellow,
          surface: AppColors.bgCard,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // Use dark transition builder for all platforms to prevent white flash
            TargetPlatform.android: DarkTransitionBuilder(),
            TargetPlatform.iOS: DarkTransitionBuilder(),
          },
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
      ),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // AudioService is already initialized in main(), just verify it exists
    try {
      Get.find<AudioService>();
      debugPrint('AudioService found in AppBindings');
    } catch (e) {
      debugPrint('AudioService initializing in background...');
    }

    // Essential controllers (needed immediately)
    Get.put(IntroAudioController(), permanent: true);
    Get.put(AppLifecycleController(), permanent: true);
    Get.put(ProfileController());

    // Content controllers - needed for home screen and audio player
    Get.put(HomeController());
    Get.put(FeaturedController());
    Get.put(TodaysDillesController());
    Get.put(SeriesController());
    Get.put(MostPopularController());
    Get.put(MasterClassesController());
    Get.put(RecommendationController());
    Get.put(ExploreController());
    Get.put(ExploreAllController());

    // Lazy loaded controllers (not needed immediately)
    Get.lazyPut(() => SplashScreenController());
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => FavoriteController());
  }
}
