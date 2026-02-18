import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/const/endpoints.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/core/services/revenuecat_service.dart';
import 'package:zenslam/core/route/global_text_style.dart';
import 'package:zenslam/app/auth/login/view/login_screen.dart';
import 'package:zenslam/app/profile_flow/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:purchases_flutter/purchases_flutter.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isProcessing = false.obs;
  var activeSubscription = false.obs;
  var isTrialExpired = true.obs; // Default to true (expired/locked) until API confirms otherwise
  var trialTaken = false.obs;
  var subscriptionType = ''.obs;

  /// Whether the current user is eligible for a free trial (from RevenueCat).
  /// Defaults to false; updated after checking with the store.
  var isTrialEligible = false.obs;

  /// Free trial duration in days, read from the store product's introductory
  /// price so the paywall always matches Apple/Google configuration.
  var trialDays = 0.obs;

  var fullName = ''.obs;
  var email = ''.obs;
  var password = ''.obs;

  var pickedImage = Rx<File?>(null);
  var imageUrl = ''.obs;

  var selectedOption = RxnString();
  var selectedValues = <String>[].obs;
  var isSelected = true.obs;
  var isSwitched = false.obs;
  var obscurePassword = true.obs;

  static const String defaultAvatarUrl = 'https://i.pravatar.cc/150?img=3';

  RxBool isLoggedIn = false.obs;

  // RevenueCat state
  var rcOfferings = Rxn<Offerings>();
  var rcPackages = <Package>[].obs;

  // Fallback store products for Android when RC offerings don't include
  // monthly/annual packages (due to base plan ID mismatch in RC config).
  var fallbackMonthlyProduct = Rxn<StoreProduct>();
  var fallbackAnnualProduct = Rxn<StoreProduct>();

  String get imagePath =>
      imageUrl.value.isNotEmpty ? imageUrl.value : defaultAvatarUrl;

  void toggleSwitch(bool value) => isSwitched.value = value;
  void selectOption(String value) => selectedOption.value = value;
  void updateValue(String value) {
    selectedValues.contains(value)
        ? selectedValues.remove(value)
        : selectedValues.add(value);
  }

  void toggleSelection() => isSelected.value = !isSelected.value;
  void togglePassword() => obscurePassword.value = !obscurePassword.value;

  String? validatePassword(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    getPackage();
    loadUserName();
    _setupRevenueCatListener();
  }

  void _setupRevenueCatListener() {
    RevenueCatService.instance.addCustomerInfoUpdateListener((customerInfo) {
      final isPremium = customerInfo.entitlements.active.containsKey('Zenslam Pro');
      debugPrint('RevenueCat entitlement update: Zenslam Pro=$isPremium');
      activeSubscription.value = isPremium;
    });

    // Belt-and-suspenders: sync with RevenueCatService.isPro
    ever(RevenueCatService.instance.isPro, (bool isPro) {
      if (isPro && !activeSubscription.value) {
        activeSubscription.value = true;
      }
    });
  }

  Future<void> refreshProfile() async {
    loadUserName();
    await loadProfile();
    await getPackage();
  }

  void loadUserName() async {
    isLoggedIn.value = (await SharedPrefHelper.getAccessToken() != null)
        ? true
        : false;
    debugPrint(isLoggedIn.value.toString());
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      debugPrint('\n========== LOADING PROFILE ==========');
      debugPrint('🔄 Starting profile load...');

      final accessToken = await SharedPrefHelper.getAccessToken();

      debugPrint(
        '🔑 Access Token Retrieved: ${accessToken != null ? 'YES' : 'NO'}',
      );

      if (accessToken != null && accessToken.isNotEmpty) {
        debugPrint('✅ Token available, fetching from API...');
        await _fetchUserProfileFromApi(accessToken);
      } else {
        debugPrint('⚠️ No access token found, loading from SharedPreferences');
        await _loadFromSharedPreferences();
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error loading profile: $e');
      debugPrint('📍 Stack Trace: $stackTrace');
      await _loadFromSharedPreferences();
    }

    debugPrint('\n========== PROFILE LOAD COMPLETE ==========');
    debugPrint('👤 Full Name: "${fullName.value}"');
    debugPrint('📧 Email: "${email.value}"');
    debugPrint('🖼️  Image URL: "${imageUrl.value}"');
    debugPrint('🖼️  Image Path (getter): "$imagePath"');
    debugPrint('==========================================\n');

    isLoading.value = false;
  }

  Future<void> _fetchUserProfileFromApi(String accessToken) async {
    try {
      debugPrint('\n========== FETCHING FROM API ==========');
      debugPrint('🌐 Endpoint: auth/me (${Tables.profiles})');

      final apiResponse = await ApiService.get(
        endpoint: 'auth/me',
        token: accessToken,
      );

      debugPrint('📡 API Response Status: ${apiResponse.statusCode}');
      debugPrint('📋 API Response Success: ${apiResponse.success}');

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;
        debugPrint('✅ Successfully received response');

        if (responseData['success'] == true) {
          debugPrint('✅ API success: true');

          final userData = responseData['data']['user'];
          debugPrint('👤 User Object: $userData');

          // Login to RevenueCat with user ID
          final userId = userData['id']?.toString();
          if (userId != null && userId.isNotEmpty) {
            RevenueCatService.instance.login(userId);
          }

          final fullNameValue = userData['fullName']?.toString() ?? '';
          final emailValue = userData['email']?.toString() ?? '';
          final imageValue = userData['image']?.toString() ?? '';
          // Parse trial status from user data
          trialTaken.value = userData['trialTaken'] ?? false;
          isTrialExpired.value = userData['isTrialExpired'] ?? true; // Default to expired if not provided

          // Subscription state: Use subscription object's isActive as the source of truth.
          // This correctly handles yearly (trial or paid), monthly, and lifetime subscriptions.
          // Note: userData['activeSubscription'] may be false for trial users, so we use the subscription object.
          if (responseData['data']['subscription'] != null) {
            final subData = responseData['data']['subscription'];
            subscriptionType.value = subData['subscriptionType'] ?? '';
            activeSubscription.value = subData['isActive'] ?? false;
          } else {
            // No subscription object means user is on free tier
            activeSubscription.value = false;
            subscriptionType.value = '';
          }

          final reasonHere = userData['reasonHere'] as List<dynamic>?;
          final mostImportant = userData['mostImportant'] as List<dynamic>?;
          final practiceCommit = userData['practiceCommit'] as List<dynamic>?;
          final topGoals = userData['topGoals'] as List<dynamic>?;

          fullName.value = fullNameValue.isNotEmpty ? fullNameValue : "No Name";
          email.value = emailValue.isNotEmpty ? emailValue : "No Email";
          imageUrl.value = imageValue;
          password.value = "";
          pickedImage.value = null;

          await SharedPrefHelper.saveUserName(fullNameValue);
          await SharedPrefHelper.saveUserEmail(emailValue);
          if (imageValue.isNotEmpty) {
            await SharedPrefHelper.saveUserImage(imageValue);
          }

          debugPrint('💾 Saving preferences to SharedPreferences...');
          try {
            if (reasonHere != null && reasonHere.isNotEmpty) {
              await SharedPrefHelper.saveReasonHere(jsonEncode(reasonHere));
            }
            if (mostImportant != null && mostImportant.isNotEmpty) {
              await SharedPrefHelper.saveMostImportant(
                jsonEncode(mostImportant),
              );
            }
            if (practiceCommit != null && practiceCommit.isNotEmpty) {
              await SharedPrefHelper.savePracticeCommit(
                jsonEncode(practiceCommit),
              );
            }
            if (topGoals != null && topGoals.isNotEmpty) {
              await SharedPrefHelper.saveTopGoals(jsonEncode(topGoals));
            }
          } catch (e) {
            debugPrint('⚠️ Error saving preferences: $e');
          }
        } else {
          await _loadFromSharedPreferences();
        }
      } else {
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      debugPrint('💥 Error fetching profile from API: $e');
      await _loadFromSharedPreferences();
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      debugPrint('\n========== LOADING FROM SHARED PREFS ==========');

      var userName = await SharedPrefHelper.getUserName();
      final userEmail = await SharedPrefHelper.getUserEmail();
      final userImage = await SharedPrefHelper.getUserImage();

      // Fall back to onboarding name if no user name is set
      if (userName == null || userName.isEmpty) {
        final onboardingName = await SharedPrefHelper.getOnboardingName();
        if (onboardingName != null && onboardingName.isNotEmpty) {
          userName = onboardingName;
          debugPrint('📝 Using onboarding name: $userName');
        }
      }

      fullName.value = (userName != null && userName.isNotEmpty)
          ? userName
          : "";
      email.value = (userEmail != null && userEmail.isNotEmpty)
          ? userEmail
          : "";
      imageUrl.value = (userImage != null && userImage.isNotEmpty)
          ? userImage
          : "";
      password.value = "";
      pickedImage.value = null;
    } catch (e) {
      debugPrint('💥 Error loading from SharedPreferences: $e');
      fullName.value = "";
      email.value = "";
      imageUrl.value = "";
      password.value = "";
      pickedImage.value = null;
    }
  }

  void updateProfile({
    required String name,
    required String emailAddr,
    required String pass,
    File? imageFile,
  }) {
    fullName.value = name;
    email.value = emailAddr;
    password.value = pass;
    if (imageFile != null) pickedImage.value = imageFile;
  }

  RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  var selectedIndex = (-1).obs;

  void selectPlan(int index) {
    debugPrint('🔵 selectPlan called with index: $index');
    debugPrint('🔵 Current selectedIndex before: ${selectedIndex.value}');
    selectedIndex.value = index;
    debugPrint('🔵 New selectedIndex after: ${selectedIndex.value}');
    update();
  }

  Future<void> getPackage() async {
    final userId = await SharedPrefHelper.getUserId();
    debugPrint('User ID: $userId');
    try {
      isLoading.value = true;

      // Fetch plan metadata from backend and RevenueCat offerings in parallel
      final futures = await Future.wait([
        _fetchPlansFromBackend(userId),
        RevenueCatService.instance.getOfferings(),
      ]);

      final offerings = futures[1] as Offerings?;
      if (offerings != null) {
        rcOfferings.value = offerings;
        if (offerings.current != null) {
          rcPackages.value = offerings.current!.availablePackages;
        }

        // On Android, if monthly/annual packages are missing from the offering
        // (RC config issue with Google Play base plan IDs), fetch them directly.
        if (Platform.isAndroid && offerings.current != null) {
          final current = offerings.current!;
          if (current.monthly == null || current.annual == null) {
            try {
              final products = await Purchases.getProducts(
                ['zenslam_pro_monthly', 'zenslam_pro_yearly'],
                productCategory: ProductCategory.subscription,
              );
              for (final p in products) {
                if (p.identifier.startsWith('zenslam_pro_monthly') && current.monthly == null) {
                  fallbackMonthlyProduct.value = p;
                  debugPrint('RC fallback: monthly product loaded: ${p.identifier} ${p.priceString}');
                } else if (p.identifier.startsWith('zenslam_pro_yearly') && current.annual == null) {
                  fallbackAnnualProduct.value = p;
                  debugPrint('RC fallback: annual product loaded: ${p.identifier} ${p.priceString}');
                }
              }
            } catch (e) {
              debugPrint('RC fallback: error fetching products: $e');
            }
          }
        }

        // Check free trial eligibility and duration for the annual product
        final annualStoreProduct = offerings.current?.annual?.storeProduct ?? fallbackAnnualProduct.value;
        if (annualStoreProduct != null) {
          final annualProductId = annualStoreProduct.identifier;
          final eligibility = await RevenueCatService.instance.checkTrialEligibility([annualProductId]);
          final status = eligibility[annualProductId]?.status;
          // Show trial UI only when explicitly eligible, or when status is unknown
          // (unknown = store couldn't determine, safe to show since store handles it)
          isTrialEligible.value =
              status == IntroEligibilityStatus.introEligibilityStatusEligible ||
              status == IntroEligibilityStatus.introEligibilityStatusUnknown;

          // Read the actual trial duration from the store product so the
          // paywall shows the correct number of days (aligned with Apple/Google).
          final intro = annualStoreProduct.introductoryPrice;
          if (intro != null && intro.price == 0) {
            final units = intro.periodNumberOfUnits;
            switch (intro.periodUnit) {
              case PeriodUnit.day:
                trialDays.value = units;
                break;
              case PeriodUnit.week:
                trialDays.value = units * 7;
                break;
              case PeriodUnit.month:
                trialDays.value = units * 30;
                break;
              case PeriodUnit.year:
                trialDays.value = units * 365;
                break;
              default:
                trialDays.value = 0;
            }
          }
          debugPrint('RevenueCat: trial eligibility for $annualProductId = $status, isTrialEligible=${isTrialEligible.value}, trialDays=${trialDays.value}');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPlansFromBackend(String? userId) async {
    try {
      String url = "${Urls.baseUrl}/subscription";
      if (userId != null && userId.isNotEmpty && userId != "null") {
        url += "?userId=$userId";
      }

      final response = await https.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );
      log(
        '📡 API Response Status of subscription: ${response.statusCode} ${json.decode(response.body)}',
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugPrint('API Response of subscription: $data');
        var list = data['data'] as List;
        plans.value = list.map((e) => SubscriptionPlan.fromJson(e)).toList();

        // Check for active subscription in plan list
        selectedIndex.value = -1;

        for (int i = 0; i < plans.length; i++) {
          final plan = plans[i];
          bool isActive = plan.purchaseSubscriptions.any(
            (sub) => sub.isActive == true,
          );

          if (isActive) {
            selectedIndex.value = i;
            activeSubscription.value = true;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching plans from backend: $e');
    }
  }

  Future<void> handlePayment(SubscriptionPlan? plan) async {
    if (isProcessing.value) return;

    if (plan == null) {
      _showErrorSnackbar('Please select a plan');
      return;
    }

    isProcessing.value = true;

    try {
      // Determine which RevenueCat package to purchase based on plan type
      final offerings = rcOfferings.value ?? await RevenueCatService.instance.getOfferings();
      if (offerings == null || offerings.current == null) {
        _showErrorSnackbar('Unable to load available packages. Please try again.');
        return;
      }

      Package? package;
      StoreProduct? fallbackProduct;
      final planType = plan.subscriptionType.toUpperCase();

      if (planType == 'MONTHLY') {
        package = offerings.current!.monthly;
        fallbackProduct ??= fallbackMonthlyProduct.value;
      } else if (planType == 'YEARLY') {
        package = offerings.current!.annual;
        fallbackProduct ??= fallbackAnnualProduct.value;
      } else if (planType == 'LIFETIME') {
        package = offerings.current!.lifetime;
      }

      if (package == null && fallbackProduct == null) {
        _showErrorSnackbar('Selected plan is not available. Please try again.');
        return;
      }

      _showLoadingDialog(message: 'Preparing purchase...');

      // Trigger native purchase sheet (App Store / Play Store)
      CustomerInfo? customerInfo;
      if (package != null) {
        customerInfo = await RevenueCatService.instance.purchasePackage(package);
      } else {
        customerInfo = await RevenueCatService.instance.purchaseStoreProduct(fallbackProduct!);
      }

      _hideLoadingDialog();

      if (customerInfo == null) {
        // User cancelled the purchase
        return;
      }

      // Check if premium entitlement is now active
      final isPremium = customerInfo.entitlements.active.containsKey('Zenslam Pro');
      if (isPremium) {
        activeSubscription.value = true;
        final token = await SharedPrefHelper.getAccessToken();
        if (token == null || token.isEmpty) {
          _showSuccessWithAccountPrompt(plan.planName);
        } else {
          _showSuccessDialog(plan.planName);
        }
        // Refresh profile from backend (webhook will update DB)
        refreshProfile();
      } else {
        _showErrorSnackbar('Purchase completed but subscription not activated. Please contact support.');
      }
    } on PlatformException catch (e) {
      _hideLoadingDialog();
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _showErrorSnackbar('Purchase failed: ${e.message}');
      }
    } catch (e) {
      _hideLoadingDialog();
      _showErrorSnackbar('An error occurred: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  void _showLoadingDialog({String message = 'Processing payment...'}) {
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1F),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please do not close the app',
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  void _hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void _showSuccessDialog(String planName) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF1A1A1F),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xff466931),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Success!',
                style: globalTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have successfully upgraded to $planName',
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                  //Get.offAll(() => NavBarScreen());
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: globalTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessWithAccountPrompt(String planName) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF1A1A1F),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xff466931),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Success!',
                style: globalTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have successfully upgraded to $planName',
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to sync your subscription across devices',
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(() => LoginScreen());
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: globalTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Text(
                  'Later',
                  style: globalTextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  Future<bool> updateUserProfileViaApi({
    required String fullName,
    required String email,
    required String password,
    File? imageFile,
  }) async {
    try {
      EasyLoading.show(status: 'Updating profile...');
      debugPrint('\n\n🔴🔴🔴 UPDATE PROFILE API STARTED 🔴🔴🔴');

      final accessToken = await SharedPrefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        EasyLoading.dismiss();
        Get.snackbar('Error', 'Authentication token not found');
        return false;
      }

      final Map<String, dynamic> data = {
        'fullName': fullName,
        'email': email,
        'password': password,
      };

      final Map<String, File> files = {};
      if (imageFile != null) {
        files['file'] = imageFile;
      }

      final apiResponse = await ApiService.multipartPatch(
        endpoint: 'user/update-profile',
        data: data,
        files: files.isNotEmpty ? files : null,
        token: accessToken,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final userData = responseData['data']?['user'];

          this.fullName.value = fullName;
          this.email.value = email;
          this.password.value = password;

          await SharedPrefHelper.saveUserName(fullName);
          await SharedPrefHelper.saveUserEmail(email);

          if (imageFile != null &&
              userData != null &&
              userData['image'] != null) {
            final uploadedImageUrl = userData['image'].toString();
            await SharedPrefHelper.saveUserImage(uploadedImageUrl);
            imageUrl.value = uploadedImageUrl;
            pickedImage.value = null;
          }

          EasyLoading.dismiss();
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            duration: const Duration(seconds: 2),
          );

          loadProfile();
          return true;
        } else {
          EasyLoading.dismiss();
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to update profile',
          );
          return false;
        }
      } else {
        EasyLoading.dismiss();
        Get.snackbar('Error', apiResponse.error ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      debugPrint('💥 Error updating profile: $e');
      EasyLoading.dismiss();
      Get.snackbar('Error', 'An error occurred while updating profile');
      return false;
    }
  }

  Future<bool> updatePreferenceViaApi({
    required String preferenceType,
    required Map<String, dynamic> preferenceData,
  }) async {
    try {
      EasyLoading.show(status: 'Updating preferences...');
      debugPrint('\n\n🔴🔴🔴 UPDATE PREFERENCE API STARTED 🔴🔴🔴');

      final accessToken = await SharedPrefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        EasyLoading.dismiss();
        Get.snackbar('Error', 'Authentication token not found');
        return false;
      }

      final Map<String, dynamic> data = {};

      switch (preferenceType) {
        case 'reason':
          data['reasonHere'] = preferenceData['reasons'] ?? [];
          break;
        case 'important':
          data['mostImportant'] = preferenceData['important'] ?? [];
          break;
        case 'time':
          data['practiceCommit'] = preferenceData['time'] ?? [];
          break;
        case 'goal':
          data['topGoals'] = preferenceData['goals'] ?? [];
          break;
        default:
          EasyLoading.dismiss();
          return false;
      }

      final apiResponse = await ApiService.patch(
        endpoint: 'user/update-profile',
        data: data,
        token: accessToken,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final responseData = apiResponse.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          try {
            switch (preferenceType) {
              case 'reason':
                final reasonList = (preferenceData['reasons'] as List? ?? [])
                    .map((item) {
                      final itemStr = item.toString();
                      return itemStr.contains('assets/icons/')
                          ? _getReasonNameFromIconPath(itemStr)
                          : itemStr;
                    })
                    .toList();
                await SharedPrefHelper.saveReasonHere(jsonEncode(reasonList));
                break;
              case 'important':
                final importantList =
                    (preferenceData['important'] as List? ?? []).map((item) {
                      final itemStr = item.toString();
                      return itemStr.contains('assets/icons/')
                          ? _getImportantNameFromIconPath(itemStr)
                          : itemStr;
                    }).toList();
                await SharedPrefHelper.saveMostImportant(
                  jsonEncode(importantList),
                );
                break;
              case 'time':
                final timeList = data['practiceCommit'] as List? ?? [];
                await SharedPrefHelper.savePracticeCommit(jsonEncode(timeList));
                break;
              case 'goal':
                final goalsList = (preferenceData['goals'] as List? ?? []).map((
                  item,
                ) {
                  final itemStr = item.toString();
                  return itemStr.contains('assets/icons/')
                      ? _getGoalNameFromIconPath(itemStr)
                      : itemStr;
                }).toList();
                await SharedPrefHelper.saveTopGoals(jsonEncode(goalsList));
                break;
            }
          } catch (e) {
            debugPrint('⚠️ Error saving preferences: $e');
          }

          EasyLoading.dismiss();
          Get.snackbar('Success', 'Preferences updated successfully');
          return true;
        } else {
          EasyLoading.dismiss();
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to update preferences',
          );
          return false;
        }
      } else {
        EasyLoading.dismiss();
        Get.snackbar(
          'Error',
          apiResponse.error ?? 'Failed to update preferences',
        );
        return false;
      }
    } catch (e) {
      debugPrint('💥 Error updating preference: $e');
      EasyLoading.dismiss();
      Get.snackbar('Error', 'An error occurred while updating preferences');
      return false;
    }
  }

  String _getReasonNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/sleepicon.png":
        return "Sleep & Rest";
      case "assets/icons/stress.png":
        return "Stress & Calm";
      case "assets/icons/build.png":
        return "Build Confidence";
      case "assets/icons/focusicon.png":
        return "Focus & Discipline";
      case "assets/icons/fatherhgood.png":
        return "Fatherhood & Family";
      case "assets/icons/discover.png":
        return "Purpose & Mission";
      case "assets/icons/angreicon.png":
        return "Anger & Emotional Strength";
      case "assets/icons/brotherhood.png":
        return "Brotherhood & Connection";
      default:
        return iconPath;
    }
  }

  String _getImportantNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/stay.png":
        return "Stay Calm Under Pressure";
      case "assets/icons/build.png":
        return "Lead with Confidence";
      case "assets/icons/find.png":
        return "Find My Purpose";
      case "assets/icons/fatherhgood.png":
        return "Be Present as a Father";
      case "assets/icons/improve.png":
        return "Improve Relationships";
      case "assets/icons/sleepicon.png":
        return "Sleep Better & Recharge";
      case "assets/icons/stranged.png":
        return "Strengthen Discipline & Habits";
      case "assets/icons/mantal.png":
        return "Mental Peace & Clarity";
      case "assets/icons/relese.png":
        return "Release Stress & Anger";
      default:
        return iconPath;
    }
  }

  String _getGoalNameFromIconPath(String iconPath) {
    switch (iconPath) {
      case "assets/icons/discover.png":
        return "Discover New Practices";
      case "assets/icons/build.png":
        return "Build Consistency";
      case "assets/icons/find.png":
        return "Find Inner Peace";
      case "assets/icons/sleepicon.png":
        return "Sleep & Rest";
      case "assets/icons/brotherhood.png":
        return "Brotherhood & Connection";
      default:
        return iconPath;
    }
  }
}
