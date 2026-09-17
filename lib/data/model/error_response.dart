class ErrorResponse {
  List<Errors>? errors;

  ErrorResponse({this.errors});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    final List<Errors> parsedErrors = <Errors>[];
    final dynamic rawErrors = json['errors'];

    if (rawErrors is List) {
      for (final dynamic item in rawErrors) {
        if (item is Map) {
          parsedErrors.add(Errors.fromJson(Map<String, dynamic>.from(item)));
        } else if (item != null) {
          parsedErrors.add(Errors(message: item.toString()));
        }
      }
    } else if (rawErrors is Map) {
      final Map<String, dynamic> errorMap = Map<String, dynamic>.from(rawErrors);

      // 6Valley APIs do not always return errors in one shape. Some endpoints
      // return: {"errors": [{"code": "...", "message": "..."}]}
      // while checkout may return: {"errors": {"code": "...", "message": "..."}}.
      if (errorMap.containsKey('code') || errorMap.containsKey('message')) {
        parsedErrors.add(Errors.fromJson(errorMap));
      } else {
        errorMap.forEach((String key, dynamic value) {
          if (value is Map) {
            parsedErrors.add(Errors.fromJson(Map<String, dynamic>.from(value)));
          } else if (value is List) {
            for (final dynamic item in value) {
              if (item is Map) {
                parsedErrors.add(Errors.fromJson(Map<String, dynamic>.from(item)));
              } else if (item != null) {
                parsedErrors.add(Errors(code: key, message: item.toString()));
              }
            }
          } else if (value != null) {
            parsedErrors.add(Errors(code: key, message: value.toString()));
          }
        });
      }
    } else if (rawErrors != null) {
      parsedErrors.add(Errors(message: rawErrors.toString()));
    }

    // A number of API errors use a top-level message instead of `errors`.
    if (parsedErrors.isEmpty && json['message'] != null) {
      parsedErrors.add(Errors(message: json['message'].toString()));
    }

    errors = parsedErrors.isEmpty ? null : parsedErrors;
  }
}

class Errors {
  String? code;
  String? message;

  Errors({this.code, this.message});

  Errors.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    // Some checkout 403 responses contain only `code`. Keep it visible rather
    // than returning null and hiding the actual server-side validation reason.
    message = json['message']?.toString() ?? json['code']?.toString();
  }
}
