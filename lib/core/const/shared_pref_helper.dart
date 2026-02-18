import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const _secureStorage = FlutterSecureStorage();

  // Sensitive keys (stored in secure storage)
  static const String _keyAccessToken = "ACCESS_TOKEN";
  static const String _keyRefreshToken = "REFRESH_TOKEN";
  static const String _keyUserId = "USER_ID";
  static const String _keyUserName = "USER_NAME";
  static const String _keyUserEmail = "USER_EMAIL";
  static const String _keyUserImage = "USER_IMAGE";
  static const String _keyUserRole = "USER_ROLE";

  // Non-sensitive keys (stored in SharedPreferences)
  static const String _keyReasonHere = "REASON_HERE";
  static const String _keyMostImportant = "MOST_IMPORTANT";
  static const String _keyPracticeCommit = "PRACTICE_COMMIT";
  static const String _keyTopGoals = "TOP_GOALS";
  static const String _keyIsOnboardingCompleted = "IS_ONBOARDING_COMPLETED";
  static const String _keyOnboardingName = "ONBOARDING_NAME";
  static const String _keyOnboardingChallenge = "ONBOARDING_CHALLENGE";
  static const String _keyOnboardingTime = "ONBOARDING_TIME";
  static const String _keyPersonalityPreferences = "PERSONALITY_PREFERENCES";
  static const String _keyCommitmentRitualCompleted = "COMMITMENT_RITUAL_COMPLETED";

  // ==================== SECURE STORAGE (sensitive data) ====================

  static Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  static Future<void> saveUserId(String id) async {
    await _secureStorage.write(key: _keyUserId, value: id);
  }

  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }

  static Future<void> saveUserName(String name) async {
    await _secureStorage.write(key: _keyUserName, value: name);
  }

  static Future<String?> getUserName() async {
    return await _secureStorage.read(key: _keyUserName);
  }

  static Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: _keyUserEmail, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _keyUserEmail);
  }

  static Future<void> saveUserImage(String? image) async {
    if (image != null) {
      await _secureStorage.write(key: _keyUserImage, value: image);
    }
  }

  static Future<String?> getUserImage() async {
    return await _secureStorage.read(key: _keyUserImage);
  }

  static Future<void> saveUserRole(String role) async {
    await _secureStorage.write(key: _keyUserRole, value: role);
  }

  static Future<String?> getUserRole() async {
    return await _secureStorage.read(key: _keyUserRole);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUserName);
    await _secureStorage.delete(key: _keyUserEmail);
    await _secureStorage.delete(key: _keyUserImage);
    await _secureStorage.delete(key: _keyUserRole);
  }

  // ==================== SHARED PREFERENCES (non-sensitive data) ====================

  static Future<void> saveIsOnboardingCompleted(bool id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboardingCompleted, id);
  }

  static Future<bool?> getIsOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboardingCompleted);
  }

  static Future<void> saveReasonHere(String reasonJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReasonHere, reasonJson);
  }

  static Future<String?> getReasonHere() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReasonHere);
  }

  static Future<void> saveMostImportant(String importantJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMostImportant, importantJson);
  }

  static Future<String?> getMostImportant() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMostImportant);
  }

  static Future<void> savePracticeCommit(String commitJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPracticeCommit, commitJson);
  }

  static Future<String?> getPracticeCommit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPracticeCommit);
  }

  static Future<void> saveTopGoals(String goalsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTopGoals, goalsJson);
  }

  static Future<String?> getTopGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTopGoals);
  }

  static Future<void> saveOnboardingName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOnboardingName, name);
  }

  static Future<String?> getOnboardingName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOnboardingName);
  }

  static Future<void> clearOnboardingName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingName);
  }

  static Future<void> saveOnboardingChallenge(String challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOnboardingChallenge, challenge);
  }

  static Future<String?> getOnboardingChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOnboardingChallenge);
  }

  static Future<void> saveOnboardingTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOnboardingTime, time);
  }

  static Future<String?> getOnboardingTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOnboardingTime);
  }

  static Future<void> savePersonalityPreferences(String prefsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPersonalityPreferences, prefsJson);
  }

  static Future<String?> getPersonalityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPersonalityPreferences);
  }

  static Future<void> saveCommitmentRitualCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCommitmentRitualCompleted, completed);
  }

  static Future<bool?> getCommitmentRitualCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCommitmentRitualCompleted);
  }

  static Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingName);
    await prefs.remove(_keyOnboardingChallenge);
    await prefs.remove(_keyOnboardingTime);
    await prefs.remove(_keyPersonalityPreferences);
    await prefs.remove(_keyCommitmentRitualCompleted);
  }

  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReasonHere);
    await prefs.remove(_keyMostImportant);
    await prefs.remove(_keyPracticeCommit);
    await prefs.remove(_keyTopGoals);
  }
}
