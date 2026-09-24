import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../shared/rtl_mirrored_icon.dart';
import '../cubit/player_cubit.dart';
import 'seek_bar.dart';
import 'speed_menu.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({required this.state, required this.fullscreen, required this.onToggleFullscreen, super.key});

  final PlayerReady state;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeekBar(position: state.position, duration: state.duration, onSeek: cubit.seekTo),
        Row(
          children: [
            FButton.icon(
              variant: .ghost,
              semanticsLabel: state.isPlaying ? l10n.pause : l10n.play,
              onPress: cubit.togglePlay,
              child: RtlMirroredIcon(state.isPlaying ? FLucideIcons.pause : FLucideIcons.play),
            ),
            const Spacer(),
            SpeedMenu(speed: state.speed, onChanged: cubit.setSpeed),
            const SizedBox(width: 4),
            FButton.icon(
              variant: .ghost,
              semanticsLabel: fullscreen ? l10n.exitFullscreen : l10n.enterFullscreen,
              onPress: onToggleFullscreen,
              child: Icon(fullscreen ? FLucideIcons.minimize : FLucideIcons.maximize),
            ),
          ],
        ),
      ],
    );
  }
}
