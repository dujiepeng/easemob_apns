# easemob_apns

获取APNs deviceToken.

## Getting Started

### 设置权限

```dart
    EasemobApns.requestAuthorization(
      options: {
        AuthorizationOptions.alert,
        AuthorizationOptions.badge,
        AuthorizationOptions.sound
      },
    );
```

### 申请DeviceToken

```dart
    EasemobApns.registerDeviceToken();
```

### 注销DeviceToken

```dart
    EasemobApns.unregisterDeviceToken();
```

### 监听事件

```dart
    EasemobApns.setHandler(
      onToken: (deviceToken, error) {
        debugPrint("deviceToken: $deviceToken, error: $error");
      },
      onLaunch: (map) {
        debugPrint("onLaunch: ${map?.keys.first}");
      },
      onMessage: (map) {
        debugPrint("onMessage: ${map.keys.first}");
      },
    );
```
