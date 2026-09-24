// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Thaheen';

  @override
  String get coursesTitle => 'دوراتي';

  @override
  String get searchHint => 'ابحث عن دورة أو مدرّب';

  @override
  String get continueWatching => 'تابع المشاهدة';

  @override
  String lessonCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString درس',
      many: '$countString درسًا',
      few: '$countString دروس',
      two: 'درسان',
      one: 'درس واحد',
      zero: 'لا توجد دروس',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString٪ مكتمل';
  }

  @override
  String get noCoursesTitle => 'لا توجد دورات بعد';

  @override
  String get noCoursesBody => 'ستظهر دوراتك هنا فور إضافتها.';

  @override
  String get noResultsTitle => 'لا توجد نتائج';

  @override
  String noResultsBody(String query) {
    return 'لم نعثر على دورات تطابق «$query».';
  }

  @override
  String get loadErrorTitle => 'تعذّر تحميل الدورات';

  @override
  String get loadErrorBody => 'حدث خطأ أثناء قراءة بيانات الدورات. حاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get back => 'رجوع';

  @override
  String get courseNotFoundTitle => 'الدورة غير موجودة';

  @override
  String get courseNotFoundBody => 'ربما حُذفت هذه الدورة أو تغيّر رابطها.';

  @override
  String get lessonNotFoundTitle => 'الدرس غير موجود';

  @override
  String get lessonNotFoundBody => 'ربما حُذف هذا الدرس أو تغيّر رابطه.';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get goHome => 'العودة إلى الدورات';

  @override
  String get emptyCourseTitle => 'لا توجد دروس بعد';

  @override
  String get emptyCourseBody => 'لم تُضف دروس إلى هذه الدورة حتى الآن.';

  @override
  String get emptySection => 'لا توجد دروس في هذا القسم بعد.';

  @override
  String get statusNotStarted => 'لم يبدأ';

  @override
  String get statusInProgress => 'قيد المشاهدة';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusLocked => 'مقفل';

  @override
  String lessonInProgress(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'قيد المشاهدة · $percentString٪';
  }

  @override
  String get lockedLessonTitle => 'هذا الدرس مقفل';

  @override
  String get lockedLessonBody => 'أكمل الدرس السابق أولًا لفتحه.';

  @override
  String get nextLesson => 'الدرس التالي';

  @override
  String get courseFinished => 'أحسنت! أكملت جميع دروس هذه الدورة.';

  @override
  String get lessonCompleted => 'أكملت هذا الدرس';

  @override
  String resumedFrom(String time) {
    return 'متابعة من $time';
  }

  @override
  String get videoErrorTitle => 'تعذّر تشغيل الفيديو';

  @override
  String get videoErrorBody => 'ملف الفيديو مفقود أو تالف.';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get enterFullscreen => 'ملء الشاشة';

  @override
  String get exitFullscreen => 'الخروج من ملء الشاشة';

  @override
  String get notesTitle => 'ملاحظاتي';

  @override
  String get notesHint => 'اكتب ملاحظاتك عن هذا الدرس…';

  @override
  String get switchLanguage => 'English';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';
}

/// The translations for Arabic, as used in Egypt (`ar_EG`).
class AppLocalizationsArEg extends AppLocalizationsAr {
  AppLocalizationsArEg() : super('ar_EG');
}
