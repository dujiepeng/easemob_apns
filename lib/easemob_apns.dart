import 'dart:async';

import 'package:flutter/services.dart';

/// 注册apns
class EasemobApns {
  static const MethodChannel _channel = MethodChannel('easemob_apns');

  static void Function(String? deviceToken, String? error)? onToken;
  static void Function(Map map)? onLaunch;
  static void Function(Map map)? onMessage;

  /// 申请权限
  /// Param [options] 权限选项，具体参考 [AuthorizationOptions].
  static Future<bool?> requestAuthorization({
    required Set<AuthorizationOptions> options,
  }) async {
    List list = options.toList();
    List<int> values = [];
    for (AuthorizationOptions item in list) {
      values.add(item.index);
    }
    return await _channel.invokeMethod<bool>('requestAuthorization', values);
  }

  /// 注册 deviceToken, 调用后，会从 [setHandler] 中返回结果。
  static registerDeviceToken() async {
    return await _channel.invokeMethod<bool>('registerDeviceToken');
  }

  /// 注销 deviceToken
  static unregisterDeviceToken() async {
    return await _channel.invokeMethod<bool>('unregisterDeviceToken');
  }

  /// 设置 Handler.
  /// Param [onLaunch] 启动参数。
  /// Param [onToken] deviceToken 注册结果。
  /// Param [onMessage] 收到推送消息。
  static void setHandler({
    void Function(Map? launchOptions)? onLaunch,
    void Function(String? deviceToken, String? error)? onToken,
    void Function(Map map)? onMessage,
  }) {
    onLaunch = onLaunch;
    onToken = onToken;
    onMessage = onMessage;
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onToken") {
        onToken?.call(call.arguments as String, null);
      } else if (call.method == "onTokenFail") {
        onToken?.call(null, call.arguments as String);
      } else if (call.method == "onMessage") {
        onMessage?.call(call.arguments);
      } else if (call.method == "onLaunch") {
        onLaunch?.call(call.arguments);
      }
    });

    _channel.invokeListMethod("initPlugin");
  }
}

/// 推送权限
enum AuthorizationOptions {
  /// 角标数字
  badge,

  /// 声音
  sound,

  /// 弹出alert
  alert,
}
