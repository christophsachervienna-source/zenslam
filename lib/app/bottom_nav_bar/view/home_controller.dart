import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isSelected = false.obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    checkLoginStatus();
  }

  /// Checks if user is logged in by verifying access token exists
  Future<void> checkLoginStatus() async {
    try {
      final token = await SharedPrefHelper.getAccessToken();
      isLoggedIn.value = (token != null && token.isNotEmpty);
    } catch (e) {
      isLoggedIn.value = false;
    }
  }

  /// Loads the user's name from shared preferences
  Future<void> loadUserName() async {
    try {
      final name = await SharedPrefHelper.getUserName();
      userName.value = name ?? '';
    } catch (e) {
      userName.value = '';
    }
  }

  Future<void> refreshAllControls() async {
    isLoading.value = true;
    // Refresh logic here
    isLoading.value = false;
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    // Load data logic here
    isLoading.value = false;
  }
}
