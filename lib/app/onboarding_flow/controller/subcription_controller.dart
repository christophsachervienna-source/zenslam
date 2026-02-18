import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = RxString('');

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  bool isSelected(String plan) => selectedPlan.value == plan;

  bool get isButtonEnabled => selectedPlan.value.isNotEmpty;
}
