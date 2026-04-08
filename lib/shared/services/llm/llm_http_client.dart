import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'llm_models.dart';

/// 通用 HTTP + SSE 客户端，供所有 LLM Provider 共用
class LlmHttpClient {
  final HttpClient _client = HttpClient();

  LlmHttpClient() {
    _client.connectionTimeout = const Duration(seconds: 30);
  }

  /// 发送 POST 请求，返回完整响应 body
  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    required Map<String, String> headers,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      _logRequest(url, body, headers, stream: false);
      final request = await _client.postUrl(Uri.parse(url));
      headers.forEach((k, v) => request.headers.set(k, v));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      _logResponse(url, response.statusCode, responseBody);

      if (response.statusCode == 401) {
        throw const LlmAuthException('API Key 无效或已过期');
      }
      if (response.statusCode == 429) {
        throw const LlmRateLimitException('请求频率超限，请稍后重试');
      }
      if (response.statusCode != 200) {
        throw LlmException(
          '请求失败: $responseBody',
          statusCode: response.statusCode,
        );
      }

      return jsonDecode(responseBody) as Map<String, dynamic>;
    } on SocketException catch (e) {
      developer.log(
        'POST $url failed with SocketException: ${e.message}',
        name: 'LlmHttpClient',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw LlmNetworkException('网络连接失败: ${e.message}');
    } on TimeoutException {
      developer.log(
        'POST $url timed out',
        name: 'LlmHttpClient',
        stackTrace: StackTrace.current,
      );
      throw const LlmNetworkException('请求超时');
    } catch (e, st) {
      developer.log(
        'POST $url failed unexpectedly',
        name: 'LlmHttpClient',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// 发送 POST 请求，SSE 流式返回 token
  Stream<String> postStream({
    required String url,
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async* {
    try {
      _logRequest(url, body, headers, stream: true);
      final request = await _client.postUrl(Uri.parse(url));
      headers.forEach((k, v) => request.headers.set(k, v));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));

      final response = await request.close();
      developer.log(
        'STREAM $url -> HTTP ${response.statusCode}',
        name: 'LlmHttpClient',
      );

      if (response.statusCode == 401) {
        throw const LlmAuthException('API Key 无效或已过期');
      }
      if (response.statusCode == 429) {
        throw const LlmRateLimitException('请求频率超限，请稍后重试');
      }
      if (response.statusCode != 200) {
        // 限制错误体读取长度，防止超大响应耗尽内存
        final chunks = <String>[];
        int totalLen = 0;
        await for (final chunk in response.transform(utf8.decoder)) {
          chunks.add(chunk);
          totalLen += chunk.length;
          if (totalLen > 2000) break;
        }
        final errorBody = chunks.join().substring(
            0, totalLen.clamp(0, 2000));
        throw LlmException('请求失败: $errorBody', statusCode: response.statusCode);
      }

      // 解析 SSE 流（30 秒无数据超时保护）
      String buffer = '';
      const streamTimeout = Duration(seconds: 30);
      await for (final chunk
          in response.transform(utf8.decoder).timeout(streamTimeout)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        // 最后一行可能是不完整的，保留到下次
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed == 'data: [DONE]') return;
          if (!trimmed.startsWith('data: ')) continue;

          final jsonStr = trimmed.substring(6);
          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final token = _extractToken(data);
            if (token != null && token.isNotEmpty) {
              yield token;
            }
          } on FormatException {
            // SSE 流中偶尔有非 JSON 行（如注释），安全跳过
          }
        }
      }

      // 流结束后处理 buffer 中可能残留的最后一条数据
      if (buffer.isNotEmpty) {
        final trimmed = buffer.trim();
        if (trimmed.startsWith('data: ') && trimmed != 'data: [DONE]') {
          final jsonStr = trimmed.substring(6);
          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final token = _extractToken(data);
            if (token != null && token.isNotEmpty) {
              yield token;
            }
          } on FormatException {
            // 不完整 JSON，忽略
          }
        }
      }
    } on SocketException catch (e) {
      developer.log(
        'STREAM $url failed with SocketException: ${e.message}',
        name: 'LlmHttpClient',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw LlmNetworkException('网络连接失败: ${e.message}');
    } catch (e, st) {
      developer.log(
        'STREAM $url failed unexpectedly',
        name: 'LlmHttpClient',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  void _logRequest(
    String url,
    Map<String, dynamic> body,
    Map<String, String> headers, {
    required bool stream,
  }) {
    developer.log(
      'POST $url stream=$stream model=${body['model'] ?? '<empty>'} '
      'hasAuth=${headers.containsKey('Authorization')}',
      name: 'LlmHttpClient',
    );
  }

  void _logResponse(String url, int statusCode, String responseBody) {
    final preview = responseBody.length > 500
        ? '${responseBody.substring(0, 500)}...'
        : responseBody;
    developer.log(
      'POST $url -> HTTP $statusCode body=$preview',
      name: 'LlmHttpClient',
    );
  }

  /// 从 SSE data 中提取 token 文本
  /// 支持 OpenAI 格式和 Anthropic 格式
  String? _extractToken(Map<String, dynamic> data) {
    // OpenAI 兼容格式: choices[0].delta.content
    final choices = data['choices'] as List?;
    if (choices != null && choices.isNotEmpty) {
      final delta = (choices[0] as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
      return delta?['content'] as String?;
    }

    // Anthropic 格式: delta.text (content_block_delta 事件)
    final delta = data['delta'] as Map<String, dynamic>?;
    if (delta != null) {
      return delta['text'] as String?;
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
