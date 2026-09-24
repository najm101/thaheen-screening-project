import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../core/context_extensions.dart';

void showLockedLessonToast(BuildContext context) => showFToast(
  context: context,
  icon: const Icon(FLucideIcons.lock),
  title: Text(context.l10n.lockedLessonTitle),
  description: Text(context.l10n.lockedLessonBody),
  duration: const Duration(seconds: 3),
);

void showInfoToast(BuildContext context, {required IconData icon, required String title}) =>
    showFToast(context: context, icon: Icon(icon), title: Text(title), duration: const Duration(seconds: 2));
