import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../core/formatting.dart';

/// FSlider picks its layout from [Directionality], so in Arabic the timeline
/// fills right-to-left, consistent with the rest of the mirrored UI.
class SeekBar extends StatefulWidget {
  const SeekBar({required this.position, required this.duration, required this.onSeek, super.key});

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragFraction;

  double get _playbackFraction {
    final total = widget.duration.inMilliseconds;
    if (total <= 0) return 0;
    return (widget.position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography.body;
    final fraction = _dragFraction ?? _playbackFraction;
    final shownPosition = _dragFraction == null ? widget.position : widget.duration * fraction;
    final timeStyle = typography.xs.copyWith(
      color: colors.mutedForeground,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Text(formatDuration(shownPosition, context.localeName), style: timeStyle),
        ),
        Expanded(
          child: FSlider(
            enabled: widget.duration > Duration.zero,
            control: .liftedContinuous(
              value: FSliderValue(max: fraction),
              onChange: (value) => setState(() => _dragFraction = value.max),
            ),
            tooltipBuilder: (_, value) => Text(formatDuration(widget.duration * value, context.localeName)),
            onEnd: (value) {
              widget.onSeek(widget.duration * value.max);
              setState(() => _dragFraction = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Text(formatDuration(widget.duration, context.localeName), style: timeStyle),
        ),
      ],
    );
  }
}
