
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCandiesJPush {
  static const MethodChannel _channel = MethodChannel('flutter_candies_jpush');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }


}
