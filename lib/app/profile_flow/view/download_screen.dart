import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/app/explore/controller/explore_controller.dart';
import 'package:zenslam/app/explore/view/audio_player_screen.dart';
import 'package:zenslam/app/explore/view/widget/mini_player_widget.dart';
import 'package:zenslam/app/onboarding_flow/controller/download_controller.dart';
import 'package:zenslam/app/onboarding_flow/theme/questionnaire_theme.dart';
import 'package:zenslam/app/profile_flow/widgets/download_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadScreen extends StatelessWidget {
  DownloadScreen({super.key});
  final DownloadController downloadController = Get.put(DownloadController());
  final ExploreController exploreController = Get.find<ExploreController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestionnaireTheme.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Premium header - matching Profile page style
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: QuestionnaireTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Downloads',
                        style: QuestionnaireTheme.headline(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RefreshIndicator(
                      onRefresh: () => downloadController.loadDownloads(),
                      color: AppColors.primaryColor,
                      backgroundColor: Colors.transparent,
                      child: Obx(() {
                        if (downloadController.isLoading.value &&
                            downloadController.downloadedAudios.isEmpty) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          );
                        }

                        final downloadedAudios =
                            downloadController.downloadedAudios;

                        if (downloadedAudios.isEmpty) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline_outlined,
                                      size: 64,
                                      color: QuestionnaireTheme.textTertiary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Downloads Yet',
                                      style: QuestionnaireTheme.titleMedium(),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Downloaded content will appear here',
                                      style: QuestionnaireTheme.bodySmall(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: downloadedAudios.length,
                          itemBuilder: (context, index) {
                            final audioData = downloadedAudios[index];
                            return DownloadCard(
                              item: audioData,
                              onTap: () {
                                Get.to(
                                  () => AudioPlayerScreen(),
                                  arguments: {
                                    'id': audioData['id'],
                                    'author': audioData['author'],
                                    'title': audioData['title'],
                                    'description':
                                        audioData['description'] ?? '',
                                    'imageUrl':
                                        audioData['localThumbnailPath'] ??
                                        audioData['thumbnail'] ??
                                        audioData['imageUrl'] ??
                                        '',
                                    'audio':
                                        audioData['localPath'] ??
                                        audioData['content'],
                                    'category': audioData['category'] ?? '',
                                    'duration': audioData['duration'],
                                  },
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayerWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
