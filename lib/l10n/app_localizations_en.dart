// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thaheen';

  @override
  String get coursesTitle => 'My courses';

  @override
  String get searchHint => 'Search courses or instructors';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String lessonCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString% complete';
  }

  @override
  String get noCoursesTitle => 'No courses yet';

  @override
  String get noCoursesBody => 'Your courses will show up here once they\'re added.';

  @override
  String get noResultsTitle => 'No results';

  @override
  String noResultsBody(String query) {
    return 'We couldn\'t find courses matching “$query”.';
  }

  @override
  String get loadErrorTitle => 'Couldn\'t load courses';

  @override
  String get loadErrorBody => 'Something went wrong while reading the course data. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get back => 'Back';

  @override
  String get courseNotFoundTitle => 'Course not found';

  @override
  String get courseNotFoundBody => 'This course may have been removed or its link changed.';

  @override
  String get lessonNotFoundTitle => 'Lesson not found';

  @override
  String get lessonNotFoundBody => 'This lesson may have been removed or its link changed.';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get goHome => 'Back to courses';

  @override
  String get emptyCourseTitle => 'No lessons yet';

  @override
  String get emptyCourseBody => 'No lessons have been added to this course yet.';

  @override
  String get emptySection => 'No lessons in this section yet.';

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusLocked => 'Locked';

  @override
  String lessonInProgress(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'In progress · $percentString%';
  }

  @override
  String get lockedLessonTitle => 'This lesson is locked';

  @override
  String get lockedLessonBody => 'Finish the previous lesson to unlock it.';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get courseFinished => 'Well done! You\'ve finished every lesson in this course.';

  @override
  String get lessonCompleted => 'Lesson completed';

  @override
  String resumedFrom(String time) {
    return 'Resuming from $time';
  }

  @override
  String get videoErrorTitle => 'Couldn\'t play this video';

  @override
  String get videoErrorBody => 'The video file is missing or corrupted.';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get enterFullscreen => 'Enter fullscreen';

  @override
  String get exitFullscreen => 'Exit fullscreen';

  @override
  String get notesTitle => 'My notes';

  @override
  String get notesHint => 'Write your notes about this lesson…';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}
