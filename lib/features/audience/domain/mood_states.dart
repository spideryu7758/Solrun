import 'audience_roles.dart';
import 'personalities.dart';

/// 今日状态枚举（跑前选择）
/// 影响角色和人格的抽取权重
///
/// 代号用于 name 属性存入数据库
enum MoodState {
  motivate,  // 🔥 激励我
  comfort,   // 🫂 安慰我
  provoke,   // 😈 刺激我
  amuse,     // 😎 逗我笑
  focus,     // 🎯 专注跑
}

extension MoodStateMeta on MoodState {
  /// 状态 emoji
  String get emoji {
    switch (this) {
      case MoodState.motivate:
        return '🔥';
      case MoodState.comfort:
        return '🫂';
      case MoodState.provoke:
        return '😈';
      case MoodState.amuse:
        return '😎';
      case MoodState.focus:
        return '🎯';
    }
  }

  /// 中文名
  String get displayName {
    switch (this) {
      case MoodState.motivate:
        return '激励我';
      case MoodState.comfort:
        return '安慰我';
      case MoodState.provoke:
        return '刺激我';
      case MoodState.amuse:
        return '逗我笑';
      case MoodState.focus:
        return '专注跑';
    }
  }

  /// 国际化key
  String get arKeyName => 'audience_mood_${name}';

  /// prompt 中的倾向提示文本（设计文档 6.3 节）
  String get promptHint {
    switch (this) {
      case MoodState.motivate:
        return '跑者今天想被激励。多强调进步、突破和正面的数据变化。'
            '即使数据一般，也尝试从中找到亮点来放大。';
      case MoodState.comfort:
        return '跑者今天想被安慰。淡化数据压力，强调过程和坚持本身的意义。'
            '如果数据不好，不要回避但要温和对待。';
      case MoodState.provoke:
        return '跑者今天想被刺激。不用客气，拿最扎心的数据说事。'
            '越是"不留情面"越好，跑者就是来找虐的。';
      case MoodState.amuse:
        return '跑者今天想被逗笑。优先搞笑效果，数据是段子的素材。'
            '冷笑话、类比、夸张都可以用，目标是让人笑出声。';
      case MoodState.focus:
        return '跑者今天想专注跑步，不想被过多打扰。'
            '言简意赅，只说一句关键信息，不废话。';
    }
  }

  /// 英文 prompt 提示
  String get promptHintEn {
    switch (this) {
      case MoodState.motivate:
        return 'The runner wants motivation today. Emphasize progress, breakthroughs, and positive data changes. '
            'Even if data is average, find highlights to amplify.';
      case MoodState.comfort:
        return 'The runner wants comfort today. Downplay data pressure, emphasize the meaning of perseverance. '
            'If data is bad, don\'t avoid it but be gentle.';
      case MoodState.provoke:
        return 'The runner wants to be challenged today. Don\'t hold back — use the most painful data. '
            'The more ruthless the better — the runner came looking for it.';
      case MoodState.amuse:
        return 'The runner wants to laugh today. Prioritize humor — data is material for jokes. '
            'Dad jokes, analogies, exaggeration — goal is to make them laugh out loud.';
      case MoodState.focus:
        return 'The runner wants to focus on running today, minimal distraction. '
            'Keep it brief — one key piece of info, no filler.';
    }
  }

  /// 根据语言获取 prompt 提示
  String promptHintFor(String lang) =>
      lang == 'en' ? promptHintEn : promptHint;

  // ── 权重矩阵（设计文档 3.2 节）──

  /// 角色权重：数值越高被抽中概率越大
  static const Map<AudienceRole, Map<MoodState, double>> _roleWeightMatrix = {
    AudienceRole.screamingFan: {
      MoodState.motivate: 2.0,
      MoodState.comfort: 1.0,
      MoodState.provoke: 0.3,
      MoodState.amuse: 1.0,
      MoodState.focus: 0.3,
    },
    AudienceRole.dataNerd: {
      MoodState.motivate: 1.0,
      MoodState.comfort: 0.5,
      MoodState.provoke: 1.0,
      MoodState.amuse: 0.8,
      MoodState.focus: 2.0,
    },
    AudienceRole.familyCrew: {
      MoodState.motivate: 1.5,
      MoodState.comfort: 2.0,
      MoodState.provoke: 0.3,
      MoodState.amuse: 1.0,
      MoodState.focus: 0.5,
    },
    AudienceRole.zenViewer: {
      MoodState.motivate: 0.8,
      MoodState.comfort: 2.0,
      MoodState.provoke: 0.2,
      MoodState.amuse: 1.0,
      MoodState.focus: 1.5,
    },
    AudienceRole.gambler: {
      MoodState.motivate: 1.5,
      MoodState.comfort: 0.5,
      MoodState.provoke: 1.5,
      MoodState.amuse: 2.0,
      MoodState.focus: 0.5,
    },
    AudienceRole.nitpicker: {
      MoodState.motivate: 0.3,
      MoodState.comfort: 0.2,
      MoodState.provoke: 2.0,
      MoodState.amuse: 1.0,
      MoodState.focus: 0.5,
    },
    AudienceRole.rivalFan: {
      MoodState.motivate: 0.3,
      MoodState.comfort: 0.2,
      MoodState.provoke: 2.0,
      MoodState.amuse: 1.5,
      MoodState.focus: 0.5,
    },
  };

  /// 人格权重
  static const Map<Personality, Map<MoodState, double>> _personalityWeightMatrix = {
    Personality.hypeCoach: {
      MoodState.motivate: 2.0,
      MoodState.comfort: 1.0,
      MoodState.provoke: 1.0,
      MoodState.amuse: 0.8,
      MoodState.focus: 1.0,
    },
    Personality.savage: {
      MoodState.motivate: 0.5,
      MoodState.comfort: 0.3,
      MoodState.provoke: 2.0,
      MoodState.amuse: 1.0,
      MoodState.focus: 0.5,
    },
    Personality.poet: {
      MoodState.motivate: 1.0,
      MoodState.comfort: 2.0,
      MoodState.provoke: 0.5,
      MoodState.amuse: 0.8,
      MoodState.focus: 1.0,
    },
    Personality.clown: {
      MoodState.motivate: 0.8,
      MoodState.comfort: 0.8,
      MoodState.provoke: 0.8,
      MoodState.amuse: 2.0,
      MoodState.focus: 0.3,
    },
    Personality.commentator: {
      MoodState.motivate: 1.0,
      MoodState.comfort: 0.5,
      MoodState.provoke: 1.0,
      MoodState.amuse: 0.5,
      MoodState.focus: 2.0,
    },
  };

  /// 获取指定状态下的角色权重
  Map<AudienceRole, double> roleWeights() {
    final weights = <AudienceRole, double>{};
    for (final role in AudienceRole.values) {
      weights[role] = _roleWeightMatrix[role]?[this] ?? 1.0;
    }
    return weights;
  }

  /// 获取指定状态下的人格权重
  Map<Personality, double> personalityWeights() {
    final weights = <Personality, double>{};
    for (final p in Personality.values) {
      weights[p] = _personalityWeightMatrix[p]?[this] ?? 1.0;
    }
    return weights;
  }

  /// 从数据库存储的字符串反序列化为枚举
  static MoodState fromName(String name) {
    return MoodState.values.firstWhere(
      (e) => e.name == name,
      orElse: () => MoodState.motivate,
    );
  }
}
