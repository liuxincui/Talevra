class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);
  @override
  String toString() => 'ApiException($status): $message';
}

class ApiResult<T> {
  final String message;
  final int status;
  final String? requestId;
  final T? data;
  const ApiResult({
    required this.message,
    required this.status,
    this.requestId,
    this.data,
  });
  bool get isSuccess => status == 0;
  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? parse,
  ) => ApiResult(
    message: '${json['msg'] ?? ''}',
    status: (json['status'] as num?)?.toInt() ?? -1,
    requestId: json['request_id'] as String?,
    data: parse == null ? null : parse(json['data']),
  );
  T requireData() {
    if (!isSuccess) throw ApiException(status, message);
    if (data == null) throw const ApiException(-1, 'empty response');
    return data as T;
  }
}
