import 'package:drift/drift.dart';

import '../database.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  /// 插入一条消息
  Future<int> insertMessage(ChatMessagesCompanion msg) {
    return into(chatMessages).insert(msg);
  }

  /// 获取某次对话的所有消息
  Future<List<ChatMessage>> getConversation(String conversationId) {
    return (select(chatMessages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// 监听某次对话的消息流
  Stream<List<ChatMessage>> watchConversation(String conversationId) {
    return (select(chatMessages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// 获取所有对话列表（每个 conversationId 的最新一条消息）
  ///
  /// 使用 customSelect 而非 Drift 原生 API 的原因：
  /// 需要「按 conversation_id 分组取每组 MAX(id)」的子查询，
  /// Drift 的 select DSL 不直接支持 GROUP BY + 子查询嵌套。
  /// 手动映射字段与 ChatMessages 表定义保持一致（id, conversation_id,
  /// role, content, session_id, summary_type, created_at）。
  Future<List<ChatMessage>> getConversationList() async {
    final result = await customSelect(
      'SELECT * FROM chat_messages WHERE id IN '
      '(SELECT MAX(id) FROM chat_messages GROUP BY conversation_id) '
      'ORDER BY created_at DESC',
      readsFrom: {chatMessages},
    ).get();

    return result.map((row) => ChatMessage(
      id: row.read<int>('id'),
      conversationId: row.read<String>('conversation_id'),
      role: row.read<String>('role'),
      content: row.read<String>('content'),
      sessionId: row.readNullable<int>('session_id'),
      summaryType: row.readNullable<String>('summary_type'),
      createdAt: row.read<DateTime>('created_at'),
    )).toList();
  }

  /// 删除某次对话的所有消息
  Future<int> deleteConversation(String conversationId) {
    return (delete(chatMessages)
      ..where((t) => t.conversationId.equals(conversationId)))
        .go();
  }

  /// 清空所有聊天记录
  Future<int> clearAll() {
    return delete(chatMessages).go();
  }

  /// 获取聊天记录统计（条数 + 估算大小）
  Future<ChatStorageInfo> getStorageInfo() async {
    final countResult = await customSelect(
      'SELECT COUNT(*) AS cnt, COALESCE(SUM(LENGTH(content)), 0) AS total_bytes FROM chat_messages',
      readsFrom: {chatMessages},
    ).getSingle();
    return ChatStorageInfo(
      messageCount: countResult.read<int>('cnt'),
      estimatedBytes: countResult.read<int>('total_bytes'),
    );
  }
}

/// 聊天记录存储信息
class ChatStorageInfo {
  final int messageCount;
  final int estimatedBytes;

  const ChatStorageInfo({required this.messageCount, required this.estimatedBytes});

  /// 格式化为可读大小
  String get formattedSize {
    if (estimatedBytes < 1024) return '$estimatedBytes B';
    if (estimatedBytes < 1024 * 1024) return '${(estimatedBytes / 1024).toStringAsFixed(1)} KB';
    return '${(estimatedBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
