import 'dart:convert';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class AutoResolverService {
  // Наш работающий эндпоинт авторегистрации
  static const String _resolverUrl = "https://panel.rusalkavpn.com/api/v1/resolve-sub";

  /// Получает уникальный Android ID устройства (магнитолы Geely)
  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id.isNotEmpty ? androidInfo.id : "unknown_geely";
    } catch (e) {
      developer.log("Ошибка получения Android ID: $e", name: "AutoResolver");
      return "unknown_geely";
    }
  }

  /// Запрашивает у сервера ссылку на подписку
  static Future<String?> fetchSubscriptionUrl() async {
    try {
      final deviceId = await getDeviceId();
      final uri = Uri.parse("$_resolverUrl?device_id=$deviceId");

      developer.log("Запрос подписки для устройства: $deviceId", name: "AutoResolver");

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['subscription_url'] != null) {
          final subUrl = data['subscription_url'] as String;
          developer.log("Подписка успешно получена: $subUrl", name: "AutoResolver");
          return subUrl;
        }
      } else {
        developer.log("Сервер вернул ошибку HTTP ${response.statusCode}", name: "AutoResolver");
      }
    } catch (e) {
      developer.log("Ошибка сети или таймаут при получении подписки: $e", name: "AutoResolver");
    }
    return null;
  }
}
