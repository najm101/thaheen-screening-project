import 'package:flutter/widgets.dart';

import 'device_shell_native.dart' if (dart.library.js_interop) 'device_shell_web.dart' as platform;

/// What the app asks of the thing it runs inside: the OS on a phone, or the
/// phone frame page on the web demo.
abstract interface class DeviceShell {
  factory DeviceShell() = platform.PlatformDeviceShell;

  Future<void> lockPortrait();

  Future<void> setFullscreen(bool fullscreen);

  void setBrightness(Brightness brightness);
}
