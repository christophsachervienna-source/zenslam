import 'package:zenslam/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/route/icons_path.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _buildIcon({
    required IconData materialIcon,
    required IconData materialActiveIcon,
    required String assetPath,
    required String activeAssetPath,
    required bool isActive,
    required String label,
  }) {
    // Use Material Icons on web for reliability, asset icons on native
    if (kIsWeb) {
      return Icon(
        isActive ? materialActiveIcon : materialIcon,
        size: 24,
      );
    }
    return Semantics(
      label: '$label tab${isActive ? ', selected' : ''}',
      child: ImageIcon(AssetImage(isActive ? activeAssetPath : assetPath), size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: const Color(0xFF6B7280),
            selectedItemColor: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            iconSize: 24,
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(
                  materialIcon: Icons.home_outlined,
                  materialActiveIcon: Icons.home_rounded,
                  assetPath: IconsPath.home,
                  activeAssetPath: IconsPath.homeFill,
                  isActive: currentIndex == 0,
                  label: 'Home',
                ),
                activeIcon: _buildIcon(
                  materialIcon: Icons.home_outlined,
                  materialActiveIcon: Icons.home_rounded,
                  assetPath: IconsPath.home,
                  activeAssetPath: IconsPath.homeFill,
                  isActive: true,
                  label: 'Home',
                ),
                label: 'Home',
                tooltip: 'Navigate to Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  materialIcon: Icons.explore_outlined,
                  materialActiveIcon: Icons.explore_rounded,
                  assetPath: IconsPath.exploreicon,
                  activeAssetPath: IconsPath.explorefill,
                  isActive: currentIndex == 1,
                  label: 'Explore',
                ),
                activeIcon: _buildIcon(
                  materialIcon: Icons.explore_outlined,
                  materialActiveIcon: Icons.explore_rounded,
                  assetPath: IconsPath.exploreicon,
                  activeAssetPath: IconsPath.explorefill,
                  isActive: true,
                  label: 'Explore',
                ),
                label: 'Explore',
                tooltip: 'Browse meditation categories',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  materialIcon: Icons.chat_bubble_outline_rounded,
                  materialActiveIcon: Icons.chat_bubble_rounded,
                  assetPath: IconsPath.mentoricon,
                  activeAssetPath: IconsPath.mentorfill,
                  isActive: currentIndex == 2,
                  label: 'Coach',
                ),
                activeIcon: _buildIcon(
                  materialIcon: Icons.chat_bubble_outline_rounded,
                  materialActiveIcon: Icons.chat_bubble_rounded,
                  assetPath: IconsPath.mentoricon,
                  activeAssetPath: IconsPath.mentorfill,
                  isActive: true,
                  label: 'Coach',
                ),
                label: 'Coach',
                tooltip: 'Access coach content',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  materialIcon: Icons.favorite_border_rounded,
                  materialActiveIcon: Icons.favorite_rounded,
                  assetPath: IconsPath.favorite,
                  activeAssetPath: IconsPath.fill,
                  isActive: currentIndex == 3,
                  label: 'Favorite',
                ),
                activeIcon: _buildIcon(
                  materialIcon: Icons.favorite_border_rounded,
                  materialActiveIcon: Icons.favorite_rounded,
                  assetPath: IconsPath.favorite,
                  activeAssetPath: IconsPath.fill,
                  isActive: true,
                  label: 'Favorite',
                ),
                label: 'Favorites',
                tooltip: 'View your favorites',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  materialIcon: Icons.person_outline_rounded,
                  materialActiveIcon: Icons.person_rounded,
                  assetPath: IconsPath.profile,
                  activeAssetPath: IconsPath.profileFill,
                  isActive: currentIndex == 4,
                  label: 'Profile',
                ),
                activeIcon: _buildIcon(
                  materialIcon: Icons.person_outline_rounded,
                  materialActiveIcon: Icons.person_rounded,
                  assetPath: IconsPath.profile,
                  activeAssetPath: IconsPath.profileFill,
                  isActive: true,
                  label: 'Profile',
                ),
                label: 'Profile',
                tooltip: 'Manage your profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
