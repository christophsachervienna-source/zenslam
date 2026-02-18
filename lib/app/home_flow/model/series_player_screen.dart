import 'package:zenslam/core/const/app_colors.dart';
import 'package:zenslam/core/route/icons_path.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenslam/app/favorite_flow/controller/favorite_controller.dart';
import 'package:zenslam/app/home_flow/controller/series_player_controller.dart';
import 'package:zenslam/app/home_flow/model/series_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeriesPlayerScreen extends StatelessWidget {
  SeriesPlayerScreen({super.key});
  final favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments ?? {};
    final SeriesModel series = arguments['series'];
    final EpisodeModel episode = arguments['episode'];

    // Clean up old controller properly
    if (Get.isRegistered<SeriesPlayerController>()) {
      Get.delete<SeriesPlayerController>(force: true);
    }

    // Create new controller
    Get.put(SeriesPlayerController(series: series, episode: episode));

    return Scaffold(
      body: GetBuilder<SeriesPlayerController>(
        builder: (controller) {
          // Rest of your build method remains the same...
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(controller.episode.thumbnail),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(controller, favoriteController),
                    Obx(
                      () =>
                          controller.isLoading.value &&
                              controller.isLoggedIn.value
                          ? _buildLoadingIndicator(context)
                          : const SizedBox.shrink(),
                    ),
                    Obx(
                      () => !controller.isLoggedIn.value
                          ? _buildLockOverlay(context)
                          : const SizedBox.shrink(),
                    ),
                    Obx(
                      () =>
                          controller.isLoggedIn.value &&
                              !controller.isLoading.value
                          ? _buildPlayerControls(controller, context)
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                    Expanded(
                      child: Obx(() {
                        if (!controller.isLoggedIn.value) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: _buildContentInfo(controller),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              _buildLockedOtherEpisodesWithButton(controller),
                            ],
                          );
                        } else {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildContentInfo(controller),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                ),
                                _buildOtherEpisodesList(controller),
                              ],
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    SeriesPlayerController controller,
    FavoriteController favoriteController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              Get.back();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
          Row(
            children: [
              Obx(() {
                return GestureDetector(
                  onTap: controller.isDownloaded.value
                      ? () {
                          Get.dialog(
                            AlertDialog(
                              title: Text('Remove Download?'),
                              content: Text(
                                'This will remove the audio from your offline storage.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.deleteAudio();
                                  },
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : () {
                          controller.downloadAudio();
                        },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1F),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isDownloaded.value
                          ? Icons.download_done_outlined
                          : Icons.file_download_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              }),

              const SizedBox(width: 16),
              Obx(
                () => GestureDetector(
                  onTap: () {
                    favoriteController.addSeriesFavorites(
                      controller.episode.id,
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      Image.asset(
                        IconsPath.lockBg,
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Image.asset(
                          favoriteController.isItemInFavorites(
                                controller.episode.id,
                              )
                              ? IconsPath.fill
                              : IconsPath.favoriteTwo,
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(SeriesPlayerController controller, context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.154),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => controller.skipBackward(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                child: Image.asset(
                  IconsPath.videobackward,
                  height: 38,
                  width: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: MediaQuery.of(context).size.width * 0.2),

            Obx(
              () => GestureDetector(
                onTap: () => controller.togglePlayPause(),
                child: Icon(
                  controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            SizedBox(width: MediaQuery.of(context).size.width * 0.2),

            GestureDetector(
              onTap: () => controller.skipForward(),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  IconsPath.videofroward,
                  height: 38,
                  width: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              Obx(
                () => SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: AppColors.primaryColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: controller.progress.clamp(
                      0.0,
                      1.0,
                    ), // Ensure valid range
                    onChanged: (value) => controller.seekTo(value),
                  ),
                ),
              ),

              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.formattedCurrentTime,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        controller.formattedTotalTime,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentInfo(SeriesPlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode Title
            Text(
              controller.episode.title,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Episode Description
            Obx(() {
              final fullDescription = controller.episode.description;
              final isExpanded = controller.isDescriptionExpanded.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textSpan = TextSpan(
                        text: fullDescription,
                        style: GoogleFonts.dmSans(
                          color: Color(0xFF9A9A9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      );

                      final textPainter = TextPainter(
                        text: textSpan,
                        maxLines: 4,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);

                      final exceedsMaxLines = textPainter.didExceedMaxLines;
                      final shouldShowButton = exceedsMaxLines;

                      final displayText = shouldShowButton && !isExpanded
                          ? _getTextUpToMaxLines(
                              fullDescription,
                              constraints.maxWidth,
                              12,
                            )
                          : fullDescription;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayText,
                            style: GoogleFonts.dmSans(
                              color: Color(0xFF9A9A9E),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: isExpanded ? null : 4,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (shouldShowButton) const SizedBox(height: 4),
                          if (shouldShowButton)
                            GestureDetector(
                              onTap: () {
                                controller.isDescriptionExpanded.value =
                                    !isExpanded;
                              },
                              child: Text(
                                isExpanded ? 'Show Less' : 'Show More',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),

            // Episode Author
            Text(
              'By ${controller.episode.author}',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherEpisodesList(SeriesPlayerController controller) {
    final otherEpisodes = controller.recommendedEpisodes;

    if (otherEpisodes.isEmpty) return SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 20),
      itemCount: otherEpisodes.length,
      itemBuilder: (context, index) {
        final episode = otherEpisodes[index];
        return _buildEpisodeListItem(controller, episode, index + 1);
      },
    );
  }

  Widget _buildLockedOtherEpisodesWithButton(
    SeriesPlayerController controller,
  ) {
    final otherEpisodes = controller.recommendedEpisodes;

    if (otherEpisodes.isEmpty) return SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxWidth * 0.75,
          child: Stack(
            children: [
              IgnorePointer(
                child: Opacity(
                  opacity: 1,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: otherEpisodes.length,
                    itemBuilder: (context, index) {
                      final episode = otherEpisodes[index];
                      return _buildEpisodeListItem(
                        controller,
                        episode,
                        index + 1,
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFF0A0A0C).withValues(alpha: 0.8),
                        Color(0xFF0A0A0C).withValues(alpha: 1.0),
                      ],
                      stops: const [0.0, 0.55, 0.9],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 40,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.getFullAccess(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Color(0xff00071B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Get Full Access',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned.fill(
              //   top: 50,
              //   bottom: 0,
              //   child: Center(
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16),
              //       child: SizedBox(
              //         width: double.infinity,
              //         height: 48,
              //         child: ElevatedButton(
              //           onPressed: () => controller.getFullAccess(),
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: const Color(0xFFD6B585),
              //             foregroundColor: Color(0xff00071B),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(8),
              //             ),
              //             elevation: 0,
              //           ),
              //           child: Text(
              //             'Get Full Access',
              //             style: globalTextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.w800,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEpisodeListItem(
    SeriesPlayerController controller,
    EpisodeModel episode,
    int episodeNumber,
  ) {
    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Leading circular image
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(episode.thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Title and category
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '${episode.title} • ${episode.duration} min',
                  style: TextStyle(
                    color: Color(0xFF9A9A9E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Play button
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () => controller.playEpisode(episode),
              icon: Image.asset(IconsPath.play, width: 24, height: 24),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }

  Widget _buildLockOverlay(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.14),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A30),
              shape: BoxShape.circle,
            ),
            child: Image.asset(IconsPath.lockIcon, height: 26),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.105),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.154),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Image.asset(
                IconsPath.videobackward,
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
            //Image.asset(IconsPath.play, width: 40, height: 40),
            CircularProgressIndicator(),
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),

            Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                IconsPath.videofroward,
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: AppColors.primaryColor,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: AppColors.primaryColor,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(value: 0, onChanged: (value) => () {}),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00:00',
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '00:00',
                      style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _getTextUpToMaxLines(String text, double maxWidth, double fontSize) {
  final textSpan = TextSpan(
    text: text,
    style: GoogleFonts.dmSans(
      color: Color(0xFF9A9A9E),
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    ),
  );

  final textPainter = TextPainter(
    text: textSpan,
    maxLines: 4,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: maxWidth);

  // Get the end position for 4 lines
  final position = textPainter.getPositionForOffset(
    Offset(maxWidth, textPainter.preferredLineHeight * 4),
  );

  // Get the text up to the 4th line
  final endIndex =
      textPainter.getOffsetBefore(position.offset) ?? position.offset;

  // Extract the text and add ellipsis
  String result = text.substring(0, endIndex).trim();

  // Ensure we don't cut in the middle of a word if possible
  final lastSpace = result.lastIndexOf(' ');
  if (lastSpace > result.length * 0.8) {
    // Only if it's near the end
    result = result.substring(0, lastSpace).trim();
  }

  return '$result...';
}
