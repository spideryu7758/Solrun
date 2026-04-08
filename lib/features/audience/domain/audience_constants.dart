/// 观众系统集中常量定义
///
/// 所有阈值、超时、限制等配置统一管理，避免硬编码散落各处。
class AudienceConstants {
  AudienceConstants._();

  // ── LLM 调用参数 ──
  /// LLM 调用超时（秒）—— 观众喊话不要求及时性，给大模型充足时间
  static const int llmTimeoutSeconds = 60;

  /// LLM 生成最大 token 数（需兼容推理模型的 <think> 开销）
  static const int maxLlmTokens = 1024;

  /// LLM 温度（创意度）
  static const double llmTemperature = 0.9;

  /// 喊话最大字符数（grapheme cluster 安全截断）
  /// 中文 50 字 ≈ 完整句子，英文需要更多字符
  static const int maxShoutLengthZh = 50;
  static const int maxShoutLengthEn = 150;

  // ── 触发保护参数 ──
  /// 触发冷却间隔（秒）
  static const int triggerCooldownSeconds = 30;

  /// 配速异常触发阈值（偏差百分比）
  static const int paceAlertThresholdPct = 20;

  /// 单次跑步最大配速异常触发次数
  static const int maxPaceAlerts = 2;

  /// 配速异常检测最小距离（米），避免跑步初期配速不稳时误触发
  static const double paceAlertMinDistanceM = 500;
}
