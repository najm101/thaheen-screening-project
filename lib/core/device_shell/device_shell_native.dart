import 'package:flutter/services.dart';

import 'device_shell.dart';

final class PlatformDeviceShell implements DeviceShell {
  @override
  Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    if (fullscreen) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await lockPortrait();
    }
  }

  @override
  void setBrightness(Brightness brightness) {}
}
