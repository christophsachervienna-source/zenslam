import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/route/icons_path.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: const Color(0xFF9A9A9E),
          selectedItemColor: AppColors.primaryColor,
          backgroundColor: const Color(0xFF1A1A1F),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          items: [
            BottomNavigationBarItem(
              icon: Semantics(
                label: 'Home tab',
                child: ImageIcon(AssetImage(IconsPath.home), size: 25),
              ),
              activeIcon: Semantics(
                label: 'Home tab, selected',
                child: ImageIcon(AssetImage(IconsPath.homeFill), size: 25),
              ),
              label: 'Home',
              tooltip: 'Navigate to Home',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: 'Explore tab',
                child: ImageIcon(AssetImage(IconsPath.exploreicon), size: 25),
              ),
              activeIcon: Semantics(
                label: 'Explore tab, selected',
                child: ImageIcon(AssetImage(IconsPath.explorefill), size: 25),
              ),
              label: 'Explore',
              tooltip: 'Browse meditation categories',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: 'Coach tab',
                child: ImageIcon(AssetImage(IconsPath.mentoricon), size: 25),
              ),
              activeIcon: Semantics(
                label: 'Coach tab, selected',
                child: ImageIcon(AssetImage(IconsPath.mentorfill), size: 25),
              ),
              label: 'Coach',
              tooltip: 'Access coach content',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: 'Favorite tab',
                child: ImageIcon(AssetImage(IconsPath.favorite), size: 25),
              ),
              activeIcon: Semantics(
                label: 'Favorite tab, selected',
                child: ImageIcon(AssetImage(IconsPath.fill), size: 25),
              ),
              label: 'Favorite',
              tooltip: 'View your favorites',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: 'Profile tab',
                child: ImageIcon(AssetImage(IconsPath.profile), size: 25),
              ),
              activeIcon: Semantics(
                label: 'Profile tab, selected',
                child: ImageIcon(AssetImage(IconsPath.profileFill), size: 25),
              ),
              label: 'Profile',
              tooltip: 'Manage your profile',
            ),
          ],
        ),
      ),
    );
  }
}
