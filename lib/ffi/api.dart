import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import '../utils/token.dart';

/// Android and ios need to implment all the interface below:
class OctopusAPI {
  MethodChannel channel = const MethodChannel('toUniApp');
  Uint64 requestID = 0 as Uint64;

  /// 打开指定的小程序
  void openUniApp(String appId, {bool remote = false, String page = "/"}) {
    channel.invokeMethod("open",
        {'AppID': appId, "remote": remote, "page": page, "req": requestID});
  }
}

class OctopusSPI {
  MethodChannel channel = const MethodChannel('toDartApp');

  void onReceiveMessage(String appid, String event, String message) {
    print("Receive Message: $appid, $event, $message");
    switch (event) {
      case "open":
        onOpenUniApp(appid, message);
        break;
      default:
        print("Unknown event: $event, appId: $appid");
    }
  }

  void onOpenUniApp(String appid, String message) {
    print("Open UniApp: $appid, $message");
  }
}

/// SPI的处理 外部还需要做：
/// 1. 异常捕获
/// 2. 类型转换，目前定义是：序列化成json格式的String
class OctopusStub {
  /// 根据URL 跳转到指定的Flutter页面
  Future<void> jumpToDartPage(String page) async {}

  Future<String> getAccessToken() async {
    var token = await TokenStorage().readToken("access_token");
    if (token == null || token.isEmpty) {
      print('Token is null or empty');
      // todo: jump to flutter login, and close uniapp
    }
    return token!;
  }

  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置服务未启用，返回错误
      throw Exception('Location services are disabled.');
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 位置权限被拒绝，返回错误
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 位置权限被永久拒绝，返回错误
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 获取当前位置
    return await Geolocator.getCurrentPosition();
  }
}

// 扩展 Position 类，添加 toJson 方法
extension PositionToJson on Position {
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'heading': heading,
      'speed': speed,
      'speedAccuracy': speedAccuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
