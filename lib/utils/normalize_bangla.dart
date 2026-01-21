import 'package:characters/characters.dart';
import "package:unorm_dart/unorm_dart.dart" as unorm;

String normalizeBangla(String text) {
  return unorm.nfc(text);
}
