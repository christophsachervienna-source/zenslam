import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService extends GetxService {
  static const String _appleApiKey = 'appl_KtHwVKZSOcYyDpreVQXfrimuUWX';
  static const String _googleApiKey = 'goog_FblRCAscTDXkLHCmKOTldnUefWO';
  static const String _entitlementId = 'Zenslam Pro';

  static RevenueCatService get instance => Get.find<RevenueCatService>();

  final isPro = false.obs;

  CustomerInfo? _customerInfo;

  Future<RevenueCatService> initialize() async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      final apiKey = Platform.isIOS || Platform.isMacOS
          ? _appleApiKey
          : _googleApiKey;
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      await refreshCustomerInfo();
      debugPrint('RevenueCat: initialized (${Platform.operatingSystem}), isPro=${isPro.value}');
    } catch (e) {
      debugPrint('RevenueCat: init error: $e');
    }
    return this;
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    _updateProStatus(info);
  }

  void _updateProStatus(CustomerInfo info) {
    isPro.value = info.entitlements.active.containsKey(_entitlementId);
    debugPrint('RevenueCat: isPro=${isPro.value}');
  }

  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  Future<void> login(String appUserId) async {
    try {
      final result = await Purchases.logIn(appUserId);
      _updateProStatus(result.customerInfo);
      debugPrint('RevenueCat: logged in as $appUserId');
    } catch (e) {
      debugPrint('RevenueCat: login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final info = await Purchases.logOut();
      _updateProStatus(info);
      debugPrint('RevenueCat: logged out');
    } catch (e) {
      debugPrint('RevenueCat: logout error: $e');
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        debugPrint('RevenueCat: offering "${current.identifier}" — ${current.availablePackages.length} packages, monthly=${current.monthly?.storeProduct.identifier} annual=${current.annual?.storeProduct.identifier} lifetime=${current.lifetime?.storeProduct.identifier}');
      } else {
        debugPrint('RevenueCat: no current offering');
      }
      return offerings;
    } catch (e) {
      debugPrint('RevenueCat: getOfferings error: $e');
      return null;
    }
  }

  /// Check if the user is eligible for a free trial / intro offer.
  /// Returns a map of product ID -> IntroEligibility.
  Future<Map<String, IntroEligibility>> checkTrialEligibility(List<String> productIds) async {
    try {
      return await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
    } catch (e) {
      debugPrint('RevenueCat: checkTrialEligibility error: $e');
      return {};
    }
  }

  Future<CustomerInfo?> purchaseStoreProduct(StoreProduct product) async {
    try {
      debugPrint('RevenueCat: purchasing store product ${product.identifier}');
      final result = await Purchases.purchaseStoreProduct(product);
      _updateProStatus(result.customerInfo);
      return result.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: purchase cancelled');
      } else {
        debugPrint('RevenueCat: purchase error code: $errorCode');
      }
      return null;
    } catch (e) {
      debugPrint('RevenueCat: purchase error: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      debugPrint('RevenueCat: purchasing ${package.identifier}');
      final result = await Purchases.purchasePackage(package);
      _updateProStatus(result.customerInfo);
      return result.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: purchase cancelled');
      } else {
        debugPrint('RevenueCat: purchase error code: $errorCode');
      }
      return null;
    } catch (e) {
      debugPrint('RevenueCat: purchase error: $e');
      return null;
    }
  }

  /// Purchase a package matching the given subscription type (MONTHLY, YEARLY, LIFETIME).
  /// Returns true on success, false on failure/cancellation.
  Future<bool> purchasePackageByType(String subscriptionType) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        debugPrint('RevenueCat: no current offering');
        return false;
      }

      Package? package;
      final type = subscriptionType.toUpperCase();
      if (type == 'MONTHLY') {
        package = current.monthly;
      } else if (type == 'YEARLY') {
        package = current.annual;
      } else if (type == 'LIFETIME') {
        package = current.lifetime;
      }

      if (package == null) {
        // Fallback: search all available packages
        for (final p in current.availablePackages) {
          if (p.identifier.toUpperCase().contains(type)) {
            package = p;
            break;
          }
        }
      }

      if (package == null) {
        debugPrint('RevenueCat: no package found for type $subscriptionType');
        return false;
      }

      debugPrint('RevenueCat: purchasing ${package.identifier}');
      final result = await Purchases.purchasePackage(package);
      _updateProStatus(result.customerInfo);
      return isPro.value;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat: purchase cancelled');
      } else {
        debugPrint('RevenueCat: purchase error code: $errorCode');
      }
      return false;
    } catch (e) {
      debugPrint('RevenueCat: purchase error: $e');
      return false;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _updateProStatus(info);
      debugPrint('RevenueCat: purchases restored, isPro=${isPro.value}');
      return info;
    } catch (e) {
      debugPrint('RevenueCat: restore error: $e');
      return null;
    }
  }

  Future<void> refreshCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _customerInfo = info;
      _updateProStatus(info);
    } catch (e) {
      debugPrint('RevenueCat: refreshCustomerInfo error: $e');
    }
  }

  Future<void> showCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('RevenueCat: showCustomerCenter error: $e');
    }
  }
}
