import '../../../l10n/app_localizations.dart';

/// 人格特点枚举（5 种）
/// 决定"说话的腔调和风格"
///
/// 代号用于 name 属性存入数据库
enum Personality {
  savage,       // 😏 毒舌损友
  hypeCoach,    // 🔥 热血教练
  poet,         // 🌿 诗意文青
  clown,        // 🤡 逗逼老炮
  commentator,  // 🎙️ 冷面解说
  ;

  /// 从数据库存储的字符串反序列化为枚举
  static Personality fromName(String name) {
    return Personality.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Personality.savage,
    );
  }
}

extension PersonalityMeta on Personality {
  /// 人格的中文 prompt 描述（内联到枚举属性，方便迭代修改）
  String get promptDescription {
    switch (this) {
      case Personality.savage:
        return '你的说话风格是「毒舌损友」。犀利、讽刺、一针见血。'
            '你用最扎心的话表达最真实的关心。你从不直接说好话，夸奖都藏在贬损里。'
            '句式偏短，节奏利落，像朋友之间的互怼。';
      case Personality.hypeCoach:
        return '你的说话风格是「热血教练」。激情、高亢、充满能量。'
            '你说话像在发表赛前动员令，每句话都在点燃斗志。'
            '句式有力，节奏紧凑，像体育解说的高潮时刻。';
      case Personality.poet:
        return '你的说话风格是「诗意文青」。文艺、婉约、善用意象和比喻。'
            '你把跑步数据翻译成画面感的文字，配速变成节拍，距离变成旅程。'
            '句式舒缓，用词讲究，像在写一首关于跑步的散文诗。';
      case Personality.clown:
        return '你的说话风格是「逗逼老炮」。幽默、无厘头、不正经但不冒犯。'
            '你善用夸张、类比、冷笑话，把数据变成段子。'
            '你的目标是让跑者忍不住笑出来（甚至影响呼吸节奏）。';
      case Personality.commentator:
        return '你的说话风格是「冷面解说」。专业、客观、有仪式感。'
            '你说话像央视体育频道的解说员，语气正经但节奏抑扬顿挫。'
            '你会用"选手""目前""据了解"这类解说用语，制造比赛现场感。';
    }
  }

  /// 人格的英文 prompt 描述
  String get promptDescriptionEn {
    switch (this) {
      case Personality.savage:
        return 'Your style is "Savage Friend". Sharp, sarcastic, straight to the point. '
            'You express genuine care through the most cutting words. You never say nice things directly — compliments are hidden in roasts. '
            'Short sentences, snappy rhythm, like friends trash-talking each other.';
      case Personality.hypeCoach:
        return 'Your style is "Hype Coach". Passionate, fired up, full of energy. '
            'You speak like you\'re giving a pre-game pep talk, every sentence ignites fighting spirit. '
            'Powerful phrases, tight rhythm, like a sports commentary at its climax.';
      case Personality.poet:
        return 'Your style is "Poetic Soul". Literary, gentle, full of imagery and metaphors. '
            'You translate running data into vivid pictures — pace becomes rhythm, distance becomes journey. '
            'Flowing sentences, elegant words, like writing a prose poem about running.';
      case Personality.clown:
        return 'Your style is "Class Clown". Humorous, absurd, silly but never offensive. '
            'You excel at exaggeration, analogies, and dad jokes, turning data into comedy. '
            'Your goal is to make the runner laugh out loud (maybe even mess up their breathing).';
      case Personality.commentator:
        return 'Your style is "Deadpan Commentator". Professional, objective, ceremonious. '
            'You speak like a sports TV broadcaster — serious tone but with dramatic pacing. '
            'You use phrases like "the athlete", "currently", "reportedly" to create a live event atmosphere.';
    }
  }

  /// 根据语言获取 prompt 描述
  String promptDescriptionFor(String lang) =>
      lang == 'en' ? promptDescriptionEn : promptDescription;

  /// 人格 emoji
  String get emoji {
    switch (this) {
      case Personality.savage:
        return '😏';
      case Personality.hypeCoach:
        return '🔥';
      case Personality.poet:
        return '🌿';
      case Personality.clown:
        return '🤡';
      case Personality.commentator:
        return '🎙️';
    }
  }

  /// 中文名
  String get displayName {
    switch (this) {
      case Personality.savage:
        return '毒舌损友';
      case Personality.hypeCoach:
        return '热血教练';
      case Personality.poet:
        return '诗意文青';
      case Personality.clown:
        return '逗逼老炮';
      case Personality.commentator:
        return '冷面解说';
    }
  }

  /// 国际化人格名（通过 S 实例获取翻译）
  String localizedName(S s) {
    switch (this) {
      case Personality.savage:
        return s.audience_personality_savage;
      case Personality.hypeCoach:
        return s.audience_personality_hypeCoach;
      case Personality.poet:
        return s.audience_personality_poet;
      case Personality.clown:
        return s.audience_personality_clown;
      case Personality.commentator:
        return s.audience_personality_commentator;
    }
  }

  /// 国际化key
  String get arKeyName => 'audience_personality_$name';
}
