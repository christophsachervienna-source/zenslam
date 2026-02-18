import 'package:zenslam/app/home_flow/model/todays_dailies_model.dart';
import 'package:get/get.dart';
import 'dart:async';

class PlayerController extends GetxController {
  late TodaysDailiesModel currentItem;

  var isPlaying = false.obs;
  var currentPosition = 0.obs;
  var totalDuration = 300.obs;
  var isLocked = false.obs;
  var isFavorite = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    currentItem = Get.arguments as TodaysDailiesModel;
    isLocked.value = currentItem.isLocked;
    // isFavorite.value = currentItem.isFavorite.value;

    _extractDuration();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _extractDuration() {
    final subtitle = currentItem.category;
    final match = RegExp(r'(\d+)\s*min').firstMatch(subtitle);
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      totalDuration.value = minutes * 60;
    }
  }

  void togglePlayPause() {
    if (isLocked.value) {
      return;
    }

    isPlaying.value = !isPlaying.value;

    if (isPlaying.value) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentPosition.value < totalDuration.value) {
        currentPosition.value++;
      } else {
        isPlaying.value = false;
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void seekTo(double value) {
    if (isLocked.value) return;

    currentPosition.value = (value * totalDuration.value).round();

    if (isPlaying.value) {
      _stopTimer();
      _startTimer();
    }
  }

  void skipForward() {
    if (isLocked.value) return;

    final newPosition = currentPosition.value + 15;
    currentPosition.value = newPosition > totalDuration.value
        ? totalDuration.value
        : newPosition;
  }

  void skipBackward() {
    if (isLocked.value) return;

    final newPosition = currentPosition.value - 15;
    currentPosition.value = newPosition < 0 ? 0 : newPosition;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    // currentItem.isFavorite.value = isFavorite.value;

    Get.snackbar(
      'Favorite',
      isFavorite.value ? 'Added to favorites' : 'Removed from favorites',

      duration: const Duration(seconds: 2),
    );
  }

  void downloadAudio() {
    if (isLocked.value) {
      _showPremiumRequired();
      return;
    }

    Get.snackbar(
      'Download',
      'Audio download started',

      duration: const Duration(seconds: 2),
    );
  }

  void getFullAccess() {
    Get.snackbar(
      'Premium Access',
      'Redirecting to subscription...',

      duration: const Duration(seconds: 2),
    );
  }

  void _showPremiumRequired() {
    Get.snackbar(
      'Premium Required',
      'This feature requires premium subscription',

      duration: const Duration(seconds: 2),
    );
  }

  String get formattedCurrentTime {
    final minutes = currentPosition.value ~/ 60;
    final seconds = currentPosition.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTotalTime {
    final minutes = totalDuration.value ~/ 60;
    final seconds = totalDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalDuration.value == 0) return 0.0;
    return currentPosition.value / totalDuration.value;
  }
}
