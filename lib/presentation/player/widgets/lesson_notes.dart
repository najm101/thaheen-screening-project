import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../cubit/notes_cubit.dart';

class LessonNotes extends StatelessWidget {
  const LessonNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<NotesCubit, NotesState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) => switch (state) {
        NotesLoading() => const SizedBox.shrink(),
        NotesReady(:final text) => FTextField(
          label: Text(l10n.notesTitle),
          hint: l10n.notesHint,
          minLines: 3,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          control: .managed(
            initial: TextEditingValue(text: text),
            onChange: (value) => context.read<NotesCubit>().update(value.text),
          ),
        ),
      },
    );
  }
}
