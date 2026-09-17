import 'package:dio/dio.dart';
import 'package:talevra/core/network/api_client.dart';

class EarningApi {
  final Dio client;
  EarningApi([Dio? client]) : client = client ?? ApiClient.instance;
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool signed = true,
  }) async =>
      (await client.post(
            path,
            data: body,
            options: Options(extra: {'signed': signed}),
          )).data
          as Map<String, dynamic>;
  Future<Map<String, dynamic>> config(String productId, String country) => post(
    '/api/rc/app/configCenter',
    {'productId': productId, 'country': country},
  );
  Future<Map<String, dynamic>> levels(String productId, String country) =>
      post('/api/rc/level/list', {'productId': productId, 'country': country});
  Future<Map<String, dynamic>> tasks(String uid, String productId) => post(
    '/api/rc/task/all',
    {'haloUid': uid, 'productId': productId, 'showAll': true},
  );
  Future<Map<String, dynamic>> userInfo(String uid, String productId) =>
      post('/api/rc/user/getInfo', {'haloUid': uid, 'productId': productId});
  Future<Map<String, dynamic>> taskDetail(
    String uid,
    String productId,
    String taskId,
  ) => post('/api/rc/task/detail', {
    'haloUid': uid,
    'productId': productId,
    'taskId': taskId,
  });
  Future<Map<String, dynamic>> strategy(
    String uid,
    String productId,
    String country,
    String version,
  ) => post('/api/rc/strategy/info', {
    'haloUid': uid,
    'productId': productId,
    'country': country,
    'version': version,
  });
  Future<Map<String, dynamic>> action(String path, Map<String, dynamic> body) =>
      post(path, body);
  Future<Map<String, dynamic>> reportAdEvent(Map<String, dynamic> body) =>
      action('/api/rc/ad/eventInfo', body);
  Future<Map<String, dynamic>> settleAd(Map<String, dynamic> body) =>
      action('/api/rc/ad/getCoins', body);
  Future<Map<String, dynamic>> doTask(Map<String, dynamic> body) =>
      action('/api/rc/task/do', body);
  Future<Map<String, dynamic>> collectTask(Map<String, dynamic> body) =>
      action('/api/rc/task/collect', body);
}
