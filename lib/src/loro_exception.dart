/// Loro异常基类
class LoroException implements Exception {
  /// 异常消息
  final String message;
  
  /// 可选的错误码
  final int? code;
  
  /// 可选的底层错误
  final dynamic cause;

  /// 创建Loro异常
  const LoroException({
    required this.message,
    this.code,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('LoroException: $message');
    if (code != null) {
      buffer.write(', code: $code');
    }
    if (cause != null) {
      buffer.write(', cause: $cause');
    }
    return buffer.toString();
  }
}

/// 文档相关异常
class LoroDocException extends LoroException {
  /// 创建文档异常
  const LoroDocException({
    required String message,
    int? code,
    dynamic cause,
  }) : super(
          message: message,
          code: code,
          cause: cause,
        );
}

/// 文本操作异常
class LoroTextException extends LoroException {
  /// 创建文本操作异常
  const LoroTextException({
    required String message,
    int? code,
    dynamic cause,
  }) : super(
          message: message,
          code: code,
          cause: cause,
        );
}

/// 同步相关异常
class LoroSyncException extends LoroException {
  /// 创建同步异常
  const LoroSyncException({
    required String message,
    int? code,
    dynamic cause,
  }) : super(
          message: message,
          code: code,
          cause: cause,
        );
}

/// 资源释放异常
class LoroDisposeException extends LoroException {
  /// 创建资源释放异常
  const LoroDisposeException({
    required String message,
    int? code,
    dynamic cause,
  }) : super(
          message: message,
          code: code,
          cause: cause,
        );
}
