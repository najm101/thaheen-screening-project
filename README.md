# Thaheen mini LMS

A small offline student app. You browse courses, go through lessons in order, and watch bundled videos that remember where you stopped. Arabic first with full RTL, plus English and dark mode.

The task asked for a video or an APK. I included both, plus a web demo:

- **Android APK:** grab it from the [latest release](https://github.com/najm101/thaheen-screening-project/releases/latest).
- **Video:** a screen recording from my iPhone, below. It shows the empty course and the corrupt video too.
- **Web demo:** [najm101.github.io/thaheen-screening-project](https://najm101.github.io/thaheen-screening-project/). On desktop it opens inside an iPhone frame. (Heads up: some gestures might not work properly on the web.)

<p align="center">
  <video src="https://github.com/user-attachments/assets/431bf44c-3921-4880-8d4d-5b167fd5ff43" width="360" controls muted playsinline></video>
</p>





If the video doesn't play, [open it here](docs/demo.mp4).

Built with Flutter 3.47 (stable) and Dart 3.13.

## What's in it

| Area | What's there |
|---|---|
| Courses | Thumbnail, instructor, lesson count, progress %, "Continue watching", search |
| Course details | Sections, duration and status per lesson, sequential unlock with a lock message |
| Player | Play/pause, seek bar, time, 1x to 2x speed, fullscreen, resume, auto complete at 90%, next lesson |
| Saved locally | Positions, completion, notes, language, theme, last speed |
| Bonus | Arabic/English, dark mode, search, per-lesson notes, remembered speed, widget test |

## Architecture

- `domain/` is pure Dart. Every progress rule lives in `ProgressRules` (90%, unlock, course %, continue watching, resume), so they're easy to test.
- `data/` reads the bundled JSON and keeps user state in SQLite. Course content stays in the JSON.
- `presentation/` is split by feature, the same way the bloc library's own examples do it. Each feature has `cubit/` (the Cubit, with its `sealed` state in a `part` file), `view/` for the screen, `widgets/` for the smaller pieces, and one barrel file to import it all. Screens switch over the sealed state, so loading, empty and error always get handled.
- `app/` wires up `WidgetsApp.router` and go_router. `l10n/` holds the ARB files, with Arabic as the template.

I went with Cubit because every screen here is "load, then react to a stream". Bloc events would just be boilerplate for that. Dependencies come in through `RepositoryProvider`.

Progress is a Drift `watch()` stream. When the player completes a lesson, the course %, the lesson statuses and "Continue watching" all update by themselves.

Routes are nested, so a deep link rebuilds the right back stack. A redirect stops you from opening a locked lesson by URL, and the player checks the lock again anyway.

I usually go feature-first, where each feature keeps its own data, logic and UI, because it scales better as an app grows. For a task this small, layers are easier to read, so I went with them here.

### UI: Forui, zero Material imports

I wanted the app to look platform agnostic. With Material I'd spend a lot of time making it stop feeling like Android, so I built the UI with [Forui](https://forui.dev). It looks good out of the box and I use it in most of my projects right now. It's been maintained for a while too, so the risk of it getting abandoned is low.

My code only imports `package:flutter/widgets.dart` and `package:forui/forui.dart`, and the root is `WidgetsApp.router`.

To be fair, Forui and go_router still pull in `material_ui` and `cupertino_ui` internally, so Material is somewhere in the dependency graph. I just never touch it.

### Storage: Drift

- Typed SQL. Progress uses a `(courseId, lessonId)` primary key, which fits a table well.
- `watch()` queries keep every screen in sync.
- Migrations are built in, so adding a "furthest watched" column later is a schema bump.
- Repository tests can run on a real in-memory database (`NativeDatabase.memory()`).
- Hive hasn't had a release since 2022 and Isar since 2023. Both live on as community forks now (`hive_ce` and `isar_community`). SharedPreferences would work, but I'd lose types and queries.

The cost is `build_runner` codegen, which is kinda heavy for this much data. I'm fine with that trade.

### Video lifecycle

One lesson gets one page, one Cubit and one player. Lesson pages are keyed by their URL, because go_router's default key (the route pattern) kept reusing the same page when you hit "Next lesson".

`LessonPlayback` owns the `VideoPlayerController`. Commands run one at a time, anything after `dispose()` gets ignored, and dispose waits for whatever is still running. That fixed a "controller used after being disposed" crash I hit on iOS.

## JSON shape

I kept the suggested shape and changed one thing: every text field (course title, instructor, section and lesson titles) is an Arabic/English pair instead of a plain string.

```json
"title": { "ar": "العظام", "en": "Bones" }
```

That way the language switch translates the course content along with the rest of the UI. A plain string still works and gets used for both languages, so the original format loads as is. Lesson IDs only need to be unique inside their course, since progress is saved per course and lesson.

## Decisions

- A broken JSON file shows the error screen. One bad course gets skipped and logged, and the rest still load.
- 90% is measured against the real video duration from the player. `durationSec` is only for display. Once a lesson is completed, it stays completed.
- The unlock chain runs through the whole course, across sections, and skips empty ones.
- Course % is completed lessons ÷ total lessons. A course with 0 lessons shows 0%.
- Resume goes back to the saved position, unless it's within 3 seconds of the end. Then it starts over.
- Position saves every 5 seconds while playing, plus on pause, seek, leaving the screen and going to the background. A force kill loses a few seconds at most.
- RTL mirrors everything. The seek bar fills right to left in Arabic, so the play icon points left to match. Numbers use Arabic digits too (١:٠٥, ٥٠٪) through the `ar_EG` locale.
- IBM Plex Sans Arabic is bundled so Arabic looks the same on Android and iOS offline (SIL Open Font License).
- 4 courses instead of 2. The last 2 are there on purpose so you can see the edge cases yourself: Pharmacology has no lessons at all, and lesson 2 of Biochemistry points at a corrupt video file. Since that lesson can't be finished, the lessons after it stay locked.

## Known issues

- Seeking counts toward 90%, so a student can scrub near the end and complete a lesson.
- The app is locked to portrait. Landscape only happens through the fullscreen button.

## Tests

```bash
flutter test
```

- `test/domain/progress_rules_test.dart` covers the 3 required rules: the exact 90% threshold (including odd clip lengths), unlock across sections and empty sections, and course % with other courses' progress mixed in.
- `test/presentation/course_details_screen_test.dart` is one widget test, in Arabic. Tapping a locked lesson shows the lock message and stays put. Tapping an unlocked one opens it.

I kept widget tests to the one interaction the spec calls out.

## With more time

- **Seek limits.** I'd track the furthest point watched and block seeking past it, so 90% means actually watched. I'd talk to the owner first though. They might want students to skip ahead, and I'd like to keep that option.
- **Content protection.** If streaming with DRM is an option, I'd go that way. Widevine on Android and FairPlay on iOS keep the video encrypted on the device (downloads too), and screenshots and recordings come out black on their own. It would mean swapping `video_player` for a DRM-capable player, which only touches `LessonPlayback`. If it's plain video files, the easiest first step is blocking screenshots and screen recording in the app. Either way, I'd go through the options with the owner first.
- More tests: repositories on an in-memory database, and `bloc_test` for `PlayerCubit` with a fake `LessonPlayback`.

## Questions I'd ask

- Can students reach 90% by seeking, or does it have to be watched?

## Time spent

About 5 hours.
