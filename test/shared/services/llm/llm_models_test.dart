import 'package:flutter_test/flutter_test.dart';
import 'package:run_pure/shared/services/llm/llm_models.dart';

void main() {
  group('LlmProviderConfig', () {
    test('toJson() 不包含 apiKey（安全性）', () {
      final config = LlmProviderConfig(
        preset: LlmPreset.openai,
        baseUrl: 'https://api.openai.com/v1',
        apiKey: 'sk-secret-key-12345',
        model: 'gpt-4',
      );

      final json = config.toJson();

      expect(json.containsKey('apiKey'), isFalse);
      expect(json['preset'], equals('openai'));
      expect(json['baseUrl'], equals('https://api.openai.com/v1'));
      expect(json['model'], equals('gpt-4'));
    });

    test('toJson() 包含 extraHeaders', () {
      final config = LlmProviderConfig(
        preset: LlmPreset.custom,
        baseUrl: 'https://custom.api.com',
        extraHeaders: {'X-Custom': 'value'},
      );

      final json = config.toJson();
      expect(json['extraHeaders'], equals({'X-Custom': 'value'}));
    });

    test('fromJson() 反序列化正确', () {
      final json = {
        'preset': 'claude',
        'baseUrl': 'https://api.anthropic.com',
        'apiKey': 'sk-ant-123',
        'model': 'claude-3-opus',
        'extraHeaders': {'X-Test': 'val'},
      };

      final config = LlmProviderConfig.fromJson(json);

      expect(config.preset, equals(LlmPreset.claude));
      expect(config.baseUrl, equals('https://api.anthropic.com'));
      expect(config.apiKey, equals('sk-ant-123'));
      expect(config.model, equals('claude-3-opus'));
      expect(config.extraHeaders, equals({'X-Test': 'val'}));
    });

    test('fromJson() 缺省字段使用默认值', () {
      final json = {
        'preset': 'openai',
      };

      final config = LlmProviderConfig.fromJson(json);

      expect(config.baseUrl, equals(''));
      expect(config.apiKey, equals(''));
      expect(config.model, equals(''));
      expect(config.extraHeaders, isEmpty);
    });

    test('copyWith 返回新对象', () {
      final original = LlmProviderConfig(
        preset: LlmPreset.openai,
        baseUrl: 'https://api.openai.com',
        apiKey: 'key1',
        model: 'gpt-4',
      );

      final modified = original.copyWith(apiKey: 'key2');

      expect(original.apiKey, equals('key1'));
      expect(modified.apiKey, equals('key2'));
      expect(modified.preset, equals(LlmPreset.openai));
      expect(modified.baseUrl, equals('https://api.openai.com'));
    });

    test('默认构造函数字段值', () {
      const config = LlmProviderConfig(
        preset: LlmPreset.qianwen,
        baseUrl: 'https://dashscope.aliyuncs.com',
      );

      expect(config.apiKey, equals(''));
      expect(config.model, equals(''));
      expect(config.extraHeaders, isEmpty);
    });
  });

  group('ChatMessage', () {
    test('构造和字段', () {
      final msg = ChatMessage(
        role: ChatRole.user,
        content: '你好',
      );

      expect(msg.role, equals(ChatRole.user));
      expect(msg.content, equals('你好'));
      expect(msg.timestamp, isNull);
    });

    test('带 timestamp 构造', () {
      final now = DateTime(2025, 6, 15, 10, 30);
      final msg = ChatMessage(
        role: ChatRole.assistant,
        content: '你好！',
        timestamp: now,
      );

      expect(msg.timestamp, equals(now));
    });

    test('toJson() 输出正确格式', () {
      final msg = ChatMessage(
        role: ChatRole.system,
        content: '你是一个助手',
      );

      final json = msg.toJson();

      expect(json['role'], equals('system'));
      expect(json['content'], equals('你是一个助手'));
      // toJson 不包含 timestamp
      expect(json.containsKey('timestamp'), isFalse);
    });

    test('fromJson() 反序列化', () {
      final json = {
        'role': 'assistant',
        'content': '回答内容',
      };

      final msg = ChatMessage.fromJson(json);

      expect(msg.role, equals(ChatRole.assistant));
      expect(msg.content, equals('回答内容'));
      expect(msg.timestamp, isNull);
    });

    test('fromJson() 带 timestamp', () {
      final json = {
        'role': 'user',
        'content': '问题',
        'timestamp': '2025-06-15T10:30:00.000',
      };

      final msg = ChatMessage.fromJson(json);

      expect(msg.role, equals(ChatRole.user));
      expect(msg.timestamp, isNotNull);
      expect(msg.timestamp!.year, equals(2025));
    });

    test('copyWith 返回新对象', () {
      final original = ChatMessage(
        role: ChatRole.user,
        content: '原始内容',
      );

      final modified = original.copyWith(content: '修改后内容');

      expect(original.content, equals('原始内容'));
      expect(modified.content, equals('修改后内容'));
      expect(modified.role, equals(ChatRole.user));
    });

    test('三种角色枚举值', () {
      expect(ChatRole.values.length, equals(3));
      expect(ChatRole.values, contains(ChatRole.system));
      expect(ChatRole.values, contains(ChatRole.user));
      expect(ChatRole.values, contains(ChatRole.assistant));
    });
  });

  group('LlmConfig', () {
    test('默认值', () {
      const config = LlmConfig();

      expect(config.model, isNull);
      expect(config.temperature, equals(0.7));
      expect(config.maxTokens, equals(1024));
      expect(config.topP, isNull);
    });

    test('自定义值', () {
      const config = LlmConfig(
        model: 'gpt-4-turbo',
        temperature: 0.3,
        maxTokens: 2048,
        topP: 0.9,
      );

      expect(config.model, equals('gpt-4-turbo'));
      expect(config.temperature, equals(0.3));
      expect(config.maxTokens, equals(2048));
      expect(config.topP, equals(0.9));
    });
  });

  group('LLM 异常类', () {
    test('LlmException 包含 message 和 statusCode', () {
      const ex = LlmException('请求失败', statusCode: 500);
      expect(ex.message, equals('请求失败'));
      expect(ex.statusCode, equals(500));
      expect(ex.toString(), contains('500'));
      expect(ex.toString(), contains('请求失败'));
    });

    test('LlmAuthException 默认 statusCode 401', () {
      const ex = LlmAuthException('认证失败');
      expect(ex.statusCode, equals(401));
    });

    test('LlmRateLimitException 默认 statusCode 429', () {
      const ex = LlmRateLimitException('请求频率过高');
      expect(ex.statusCode, equals(429));
    });

    test('LlmNetworkException 无 statusCode', () {
      const ex = LlmNetworkException('网络超时');
      expect(ex.statusCode, isNull);
      expect(ex.message, equals('网络超时'));
    });
  });

  group('LlmPreset', () {
    test('所有厂商预设有 displayName', () {
      for (final preset in LlmPreset.values) {
        expect(preset.displayName, isNotEmpty);
      }
    });

    test('displayName 对应正确', () {
      expect(LlmPreset.openai.displayName, equals('OpenAI'));
      expect(LlmPreset.claude.displayName, equals('Claude (Anthropic)'));
      expect(LlmPreset.qianwen.displayName, equals('通义千问'));
      expect(LlmPreset.zhipu.displayName, equals('智谱 GLM'));
      expect(LlmPreset.minimax.displayName, equals('MiniMax'));
      expect(LlmPreset.openclaw.displayName, equals('OpenClaw'));
      expect(LlmPreset.custom.displayName, equals('自定义'));
    });
  });
}
