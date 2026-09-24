import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/context_extensions.dart';
import '../../../core/device_shell/device_shell.dart';
import '../../../core/formatting.dart';
import '../../shared/status_view.dart';
import '../../shared/toasts.dart';
import '../cubit/player_cubit.dart';
import '../widgets/lesson_notes.dart';
import '../widgets/player_controls.dart';
import '../widgets/video_surface.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  static const _controlsTimeout = Duration(seconds: 3);

  late final AppLifecycleListener _lifecycle;
  late final DeviceShell _shell;
  bool _fullscreen = false;
  bool _controlsVisible = true;
  Timer? _hideControls;

  @override
  void initState() {
    super.initState();
    _shell = context.read<DeviceShell>();
    _lifecycle = AppLifecycleListener(onHide: () => context.read<PlayerCubit>().pause());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _hideControls?.cancel();
    if (_fullscreen) unawaited(_shell.setFullscreen(false));
    super.dispose();
  }

  Future<void> _setFullscreen(bool fullscreen) async {
    setState(() {
      _fullscreen = fullscreen;
      _controlsVisible = true;
    });
    _scheduleHideControls();
    await _shell.setFullscreen(fullscreen);
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideControls?.cancel();
    if (!_fullscreen || !_controlsVisible) return;
    _hideControls = Timer(_controlsTimeout, () {
      if (!mounted) return;
      final state = context.read<PlayerCubit>().state;
      if (state is PlayerReady && state.isPlaying) setState(() => _controlsVisible = false);
    });
  }

  void _back() {
    if (context.canPop()) return context.pop();
    final cubit = context.read<PlayerCubit>();
    context.go(AppRoutes.course(cubit.courseId));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_fullscreen,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _fullscreen) _setFullscreen(false);
    },
    child: MultiBlocListener(
      listeners: [
        BlocListener<PlayerCubit, PlayerState>(
          listenWhen: (previous, current) =>
              previous is! PlayerReady && current is PlayerReady && current.resumedFrom > Duration.zero,
          listener: (context, state) => showInfoToast(
            context,
            icon: FLucideIcons.history,
            title: context.l10n.resumedFrom(formatDuration((state as PlayerReady).resumedFrom, context.localeName)),
          ),
        ),
        BlocListener<PlayerCubit, PlayerState>(
          listenWhen: (previous, current) =>
              previous is PlayerReady && current is PlayerReady && !previous.completed && current.completed,
          listener: (context, _) =>
              showInfoToast(context, icon: FLucideIcons.circleCheck, title: context.l10n.lessonCompleted),
        ),
        BlocListener<PlayerCubit, PlayerState>(
          listenWhen: (_, current) => _fullscreen && current is! PlayerReady,
          listener: (_, _) => _setFullscreen(false),
        ),
      ],
      child: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          if (_fullscreen && state is PlayerReady) return _buildFullscreen(state);
          return FScaffold(
            header: FHeader.nested(
              title: Text(_title(state), maxLines: 1, overflow: TextOverflow.ellipsis),
              prefixes: [FHeaderAction.back(onPress: _back)],
            ),
            child: switch (state) {
              PlayerLoading() => const LoadingView(),
              final PlayerFailure failure => _buildFailure(failure),
              final PlayerReady ready => _buildPortrait(ready),
            },
          );
        },
      ),
    ),
  );

  String _title(PlayerState state) => switch (state) {
    PlayerReady(:final lesson) || PlayerFailure(lesson: final lesson?) => context.localized(lesson.title),
    _ => '',
  };

  Widget _buildPortrait(PlayerReady state) {
    final theme = context.theme;

    return ListView(
      padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ClipRRect(
          borderRadius: theme.style.borderRadius.lg,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoSurface(
              playback: state.playback,
              isBuffering: state.isBuffering,
              onTap: context.read<PlayerCubit>().togglePlay,
            ),
          ),
        ),
        const SizedBox(height: 8),
        PlayerControls(state: state, fullscreen: false, onToggleFullscreen: () => _setFullscreen(true)),
        const SizedBox(height: 16),
        _LessonInfo(state: state),
        const SizedBox(height: 16),
        _NextLesson(state: state),
        const SizedBox(height: 24),
        const LessonNotes(),
      ],
    );
  }

  Widget _buildFullscreen(PlayerReady state) => ColoredBox(
    color: const Color(0xFF000000),
    child: Stack(
      fit: StackFit.expand,
      children: [
        VideoSurface(playback: state.playback, isBuffering: state.isBuffering, onTap: _toggleControls),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: FTheme(
                data: AppTheme.dark,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xCC000000)],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: PlayerControls(
                      state: state,
                      fullscreen: true,
                      onToggleFullscreen: () => _setFullscreen(false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFailure(PlayerFailure failure) {
    final l10n = context.l10n;
    final cubit = context.read<PlayerCubit>();
    return switch (failure.reason) {
      PlayerFailureReason.loadFailed => StatusView(
        icon: FLucideIcons.circleAlert,
        title: l10n.loadErrorTitle,
        message: l10n.loadErrorBody,
        actionLabel: l10n.retry,
        onAction: cubit.load,
        destructive: true,
      ),
      PlayerFailureReason.lessonNotFound => StatusView(
        icon: FLucideIcons.fileX,
        title: l10n.lessonNotFoundTitle,
        message: l10n.lessonNotFoundBody,
        actionLabel: l10n.goHome,
        onAction: () => context.go(AppRoutes.courses),
      ),
      PlayerFailureReason.lessonLocked => StatusView(
        icon: FLucideIcons.lock,
        title: l10n.lockedLessonTitle,
        message: l10n.lockedLessonBody,
        actionLabel: l10n.back,
        onAction: _back,
      ),
      PlayerFailureReason.videoUnavailable => StatusView(
        icon: FLucideIcons.videoOff,
        title: l10n.videoErrorTitle,
        message: l10n.videoErrorBody,
        actionLabel: l10n.retry,
        onAction: cubit.load,
        destructive: true,
      ),
    };
  }
}

class _LessonInfo extends StatelessWidget {
  const _LessonInfo({required this.state});

  final PlayerReady state;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized(state.course.title), style: typography.sm.copyWith(color: colors.mutedForeground)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                context.localized(state.lesson.title),
                style: typography.lg.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
              ),
            ),
            if (state.completed) ...[const SizedBox(width: 8), FBadge(child: Text(context.l10n.statusCompleted))],
          ],
        ),
      ],
    );
  }
}

class _NextLesson extends StatelessWidget {
  const _NextLesson({required this.state});

  final PlayerReady state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = state.nextLesson;

    if (next == null) {
      if (!state.completed) return const SizedBox.shrink();
      return FAlert(icon: const Icon(FLucideIcons.graduationCap), title: Text(l10n.courseFinished));
    }

    final unlocked = state.isNextUnlocked;
    return FButton(
      variant: unlocked ? .primary : .outline,
      onPress: () async {
        if (!unlocked) return showLockedLessonToast(context);
        final cubit = context.read<PlayerCubit>();
        await cubit.pause();
        if (context.mounted) context.go(AppRoutes.lesson(state.course.id, next.id));
      },
      prefix: unlocked ? null : const Icon(FLucideIcons.lock),
      suffix: unlocked ? const Icon(FLucideIcons.chevronRight) : null,
      child: Text('${l10n.nextLesson}: ${context.localized(next.title)}', maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
