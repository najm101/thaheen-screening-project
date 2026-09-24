import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import 'device_shell.dart';

/// Posts to the parent page so the phone frame can rotate and match the theme.
/// Outside a frame the parent is the app's own window, so messages go nowhere.
final class PlatformDeviceShell implements DeviceShell {
  @override
  Future<void> lockPortrait() async {}

  @override
  Future<void> setFullscreen(bool fullscreen) async => _post('thaheen:fullscreen', fullscreen);

  @override
  void setBrightness(Brightness brightness) => _post('thaheen:brightness', brightness.name);

  void _post(String type, Object value) {
    final parent = web.window.parent;
    if (parent == null) return;
    parent.postMessage({'type': type, 'value': value}.jsify(), web.window.location.origin.toJS);
  }
}
