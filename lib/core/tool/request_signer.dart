import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class RequestSigner {
  static const privateKey = 'R3tEWyjkMxRtTaFeAmdRNeeNOh29TJ4s';
  static const ivValue = 'N3lg4J1ihaSh6l7J';

  static Map<String, String> sign(String body, {int? timestamp}) {
    final time = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final md5Key = md5.convert(utf8.encode('$privateKey$time')).toString();
    final key = enc.Key.fromUtf8(md5Key.substring(md5Key.length - 16));
    final encrypted = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    ).encrypt(body, iv: enc.IV.fromUtf8(ivValue));
    final token = md5.convert(utf8.encode(encrypted.base64)).toString();
    return {'RequestTime': '$time', 'Token': token};
  }
}
