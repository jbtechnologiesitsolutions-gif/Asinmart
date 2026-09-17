import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/error_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class ApiErrorHandler {
  static dynamic getMessage(dynamic error) {
    if (error is! Exception) {
      return error?.toString() ?? 'Unexpected error occurred';
    }

    try {
      if (error is! DioException) {
        return 'Unexpected error occurred';
      }

      switch (error.type) {
        case DioExceptionType.cancel:
          return 'Request to API server was cancelled';
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout with API server';
        case DioExceptionType.sendTimeout:
          return 'Send timeout';
        case DioExceptionType.transformTimeout:
          return 'Transform timeout';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout in connection with API server';
        case DioExceptionType.badCertificate:
          return 'Unable to establish a secure connection';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server';
        case DioExceptionType.unknown:
          return error.message ?? 'Unexpected network error';
        case DioExceptionType.badResponse:
          final Response<dynamic>? response = error.response;
          final int? statusCode = response?.statusCode;
          final String message = _extractMessage(response?.data, statusCode);

          if (kDebugMode) {
            debugPrint('API ERROR[$statusCode] ${error.requestOptions.path}');
            debugPrint('API ERROR BODY: ${response?.data}');
            debugPrint('API ERROR MESSAGE: $message');
          }

          if (statusCode == 401) {
            try {
              Provider.of<AuthController>(Get.context!, listen: false).clearSharedData();
            } catch (_) {
              // Error parsing must never throw a second exception.
            }
          }

          return message;
      }
    } on FormatException catch (e) {
      return e.toString();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ApiErrorHandler parse failure: $e');
      }
      return 'Unexpected server response';
    }
  }

  static String _extractMessage(dynamic data, int? statusCode) {
    if (data == null) {
      return _fallbackStatusMessage(statusCode);
    }

    if (data is String) {
      return data.trim().isNotEmpty ? data : _fallbackStatusMessage(statusCode);
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      final dynamic topLevelMessage = map['message'];
      if (topLevelMessage != null && topLevelMessage.toString().trim().isNotEmpty) {
        return topLevelMessage.toString();
      }

      if (map['errors'] != null) {
        final dynamic rawErrors = map['errors'];
        if (rawErrors is Map && rawErrors['code']?.toString() == 'shipping-method') {
          return 'Please select a shipping method before checkout';
        }

        try {
          final ErrorResponse parsed = ErrorResponse.fromJson(map);
          if (parsed.errors != null && parsed.errors!.isNotEmpty) {
            final Iterable<String> messages = parsed.errors!
                .map((Errors e) => (e.message ?? e.code ?? '').trim())
                .where((String value) => value.isNotEmpty);
            if (messages.isNotEmpty) {
              return messages.join('\n');
            }
          }
        } catch (_) {
          // Continue with generic extraction below.
        }
      }

      // Laravel validation responses can also be a generic key/value map.
      for (final dynamic value in map.values) {
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    if (data is List && data.isNotEmpty) {
      final dynamic first = data.first;
      if (first is Map) {
        final dynamic message = first['message'] ?? first['code'];
        if (message != null) {
          return message.toString();
        }
      }
      return first.toString();
    }

    return _fallbackStatusMessage(statusCode);
  }

  static String _fallbackStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized request';
      case 403:
        return 'Checkout request was rejected by the server';
      case 404:
        return 'Requested resource was not found';
      case 429:
        return 'Too many requests. Please try again later';
      case 500:
        return 'Internal server error';
      case 503:
        return 'Service temporarily unavailable';
      default:
        return statusCode == null
            ? 'Unexpected server response'
            : 'Request failed - status code: $statusCode';
    }
  }
}
