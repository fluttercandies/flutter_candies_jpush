import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'local_notification.dart';

typedef EventHandler = Future<dynamic> Function(Map<String, dynamic> event);

class FlutterCandiesJPush {
  static const MethodChannel _channel = MethodChannel('flutter_candies_jpush');

  static EventHandler? _onReceiveNotification;
  static EventHandler? _onOpenNotification;
  static EventHandler? _onReceiveMessage;
  static EventHandler? _onReceiveNotificationAuthorization;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 隐私确认
  static Future<void> setAuth(bool auth) async {
    await _channel.invokeMethod("setAuth", auth);
  }

  /// 请求通知权限 IOS
  static Future<void> applyPushAuthority(
      {bool sound = true, bool alert = true, bool badge = true}) async {
    if (!Platform.isIOS) return;
    var param = {'sound': sound, 'alert': alert, 'badge': badge};
    await _channel.invokeMethod('applyPushAuthority', param);
  }

  /// 初始化SDK
  static Future<void> setup(
      {bool debug = false,
      String appKey = '',
      String channel = '',
      bool production = false}) async {
    Map<String, dynamic> param = {
      'debug': debug,
      'appKey': appKey,
      'channel': channel,
      'production': production
    };
    await _channel.invokeMethod("setup", param);
    _channel.setMethodCallHandler(_handleMethod);
  }

  /// 获取 RegistrationId
  static Future<String> getRegistrationId() async {
    return await _channel.invokeMethod("getRegistrationId");
  }

  /// 获取连接状态
  static Future<bool> getConnectionState() async {
    return await _channel.invokeMethod("getConnectionState");
  }

  /// 获取通知开关
  static Future<bool> isNotificationEnabled() async {
    return await _channel.invokeMethod("isNotificationEnabled");
  }

  /// 跳转至系统设置中应用设置界面
  static Future<void> openSettingsForNotification() async {
    await _channel.invokeMethod("openSettingsForNotification");
  }

  /// 添加一个本地通知
  static Future<void> addLocalNotification(LocalNotification notice) async {
    await _channel.invokeMethod("addLocalNotification", notice.toMap());
  }

  /// 移除一个本地通知
  static Future<void> removeLocalNotification(int id) async {
    await _channel.invokeMethod("removeLocalNotification", id);
  }

  /// 清除一个通知
  static Future<void> clearNotification(int id) async {
    await _channel.invokeMethod("clearNotification", id);
  }

  /// 清除所有通知
  static Future<void> clearAllNotifications() async {
    await _channel.invokeMethod("clearAllNotifications");
  }

  /// 获取启动App的通知
  static Future<Map<String, dynamic>> getLaunchAppNotification() async {
    return await _channel.invokeMethod("getLaunchAppNotification");
  }

  /// 停止推送服务
  static Future<void> stopPush() async {
    await _channel.invokeMethod("stopPush");
  }

  /// 恢复推送服务
  static Future<void> resumePush() async {
    await _channel.invokeMethod("resumePush");
  }

  /// 设置角标数字
  static Future<void> setBadge(int badge) async {
    await _channel.invokeMethod("setBadge", badge);
  }

  /// 设置手机号码
  static Future<bool> setMobileNumber(String mobileNumber) async {
    return await _channel.invokeMethod("setMobileNumber", mobileNumber);
  }

  /// 设置别名
  static Future<bool> setAlias(String alias) async {
    return await _channel.invokeMethod("setAlias", alias);
  }

  /// 删除别名
  static Future<bool> deleteAlias() async {
    return await _channel.invokeMethod("deleteAlias");
  }

  /// 查询别名
  static Future<String> getAlias() async {
    return await _channel.invokeMethod("getAlias");
  }

  /// 筛选有效标签
  static Future<Set<String>> filterValidTags(Set<String> tags) async {
    var tagsTmp = await _channel.invokeMethod("filterValidTags", tags.toList());
    return Set.from(tagsTmp);
  }

  /// 设置标签 覆盖操作
  static Future<bool> setTags(Set<String> tags) async {
    return await _channel.invokeMethod("setTags", tags.toList());
  }

  /// 添加标签
  static Future<bool> addTags(Set<String> tags) async {
    return await _channel.invokeMethod("addTags", tags.toList());
  }

  /// 删除标签
  static Future<bool> deleteTags(Set<String> tags) async {
    return await _channel.invokeMethod("deleteTags", tags.toList());
  }

  /// 清理标签
  static Future<bool> cleanTags() async {
    return await _channel.invokeMethod("cleanTags");
  }

  /// 获取标签
  static Future<Set<String>> getAllTags() async {
    var tagsTmp = await _channel.invokeMethod("getAllTags");
    return Set.from(tagsTmp);
  }

  /// 查询指定标签的绑定状态
  static Future<bool> checkTagBindState(String tag) async {
    return await _channel.invokeMethod("checkTagBindState", tag);
  }

  /// 设置事件处理
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onReceiveMessage,
    EventHandler? onReceiveNotificationAuthorization,
  }) {
    _onReceiveNotification = onReceiveNotification;
    _onOpenNotification = onOpenNotification;
    _onReceiveMessage = onReceiveMessage;
    _onReceiveNotificationAuthorization = onReceiveNotificationAuthorization;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onReceiveNotification":
        if (_onReceiveNotification != null) {
          _onReceiveNotification!(call.arguments.cast<String, dynamic>());
        }
        return null;
      case "onOpenNotification":
        if (_onOpenNotification != null) {
          _onOpenNotification!(call.arguments.cast<String, dynamic>());
        }
        return null;
      case "onReceiveMessage":
        if (_onReceiveMessage != null) {
          _onReceiveMessage!(call.arguments.cast<String, dynamic>());
        }
        return null;
      case "onReceiveNotificationAuthorization":
        if (_onReceiveNotificationAuthorization != null) {
          Map<String, dynamic> param = call.arguments.cast<String, bool>();
          _onReceiveNotificationAuthorization!(param);
        }
        return;
      default:
        throw UnsupportedError("Unrecognized Event");
    }
  }
}
