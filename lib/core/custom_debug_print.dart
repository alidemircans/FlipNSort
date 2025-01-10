import 'package:flutter/foundation.dart';

void customDebugPrint(Object? value) {
  if (kDebugMode) {
    debugPrint(value.toString());
  }
}
