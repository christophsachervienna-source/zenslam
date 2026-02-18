import 'package:zenslam/app/home_flow/view/redesigned_home_screen.dart';
import 'package:zenslam/app/explore/view/explore_screen.dart';
import 'package:zenslam/app/you_might_also_like/controller/favorite_screen.dart';

import 'package:zenslam/app/home_flow/view/unit_test_wrapper.dart';
import 'package:zenslam/app/home_flow/model/mentor_screen.dart';
import 'package:zenslam/app/profile_flow/view/profile_screen.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:get/get.dart';
import '../../bottom_nav_bar/controller/nav_controller.dart';
import '../../bottom_nav_bar/widget/custom_bottom_nav.dart';

class NavBarScreen extends StatelessWidget {
  NavBarScreen({super.key});

  final NavController controller = Get.put(NavController());

  final List<Widget> pages = [
    const UnitTestWrapper(child: RedesignedHomeScreen()),
    UnitTestWrapper(child: ExploreScreen()),
    UnitTestWrapper(child: MentorScreen()),
    UnitTestWrapper(child: FavoriteScreen()),
    UnitTestWrapper(child: ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        // Use IndexedStack to keep all pages alive in memory
        // This prevents widgets from being disposed when switching tabs
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
