import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../playback/lesson_playback.dart';

class VideoSurface extends StatelessWidget {
  const VideoSurface({required this.playback, required this.isBuffering, this.onTap, super.key});

  final LessonPlayback playback;
  final bool isBuffering;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: ColoredBox(
      color: const Color(0xFF000000),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PlaybackView(playback: playback),
          if (isBuffering) const FCircularProgress(),
        ],
      ),
    ),
  );
}
