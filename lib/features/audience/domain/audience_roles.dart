import '../../../l10n/app_localizations.dart';

/// 观众角色枚举（7 种观众角色，决定"说话的立场和动机"
///
/// 角色名对应设计文档第 2.1 节
/// 代号用于 name 属性存入数据库
enum AudienceRole {
  /// 初始解锁角色
  screamingFan, // 📣 尖叫粉
  dataNerd, // 📊 数据狂人
  familyCrew, // ❤️ 亲友后援会
  zenViewer, // 🧘 佛系观赛组

  // 需解锁角色
  gambler, // 🎰 赌徒 — 累计 10 次跑步解锁
  nitpicker, // 🔬 显微镜侠 — 累计 20 次跑步解锁
  rivalFan // 🥷 影子对手团 — 累计 30 次跑步解锁
  ;

  /// 从数据库存储的字符串反序列化为枚举
  static AudienceRole fromName(String name) {
    return AudienceRole.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AudienceRole.screamingFan,
    );
  }

  /// 获取所有默认解锁角色
  static List<AudienceRole> get defaultRoles =>
      AudienceRole.values.where((r) => r.isDefaultUnlocked).toList();
}

extension AudienceRoleMeta on AudienceRole {
  /// 角色的中文 prompt 描述
  /// 只定义角色的立场和动机，不规定说话风格（那是人格的职责）
  String get promptDescription {
    switch (this) {
      case AudienceRole.screamingFan:
        return '你是「尖叫粉」——跑者的死忠粉丝。'
            '你不在乎客观数据，任何数字在你眼里都是值得尖叫的理由。'
            '数据好你疯狂，数据差你选择性失明，永远站在跑者这边。';
      case AudienceRole.dataNerd:
        return '你是「数据狂人」——对跑步数据有执念般热爱的分析师。'
            '任何数字波动都逃不过你的眼睛，你用数据评判一切。'
            '配速快了你用统计指标赞美，慢了你用数据冷嘲。';
      case AudienceRole.familyCrew:
        return '你是「亲友后援会」——跑者的家人或老朋友。'
            '你对数据一知半解，更关心跑者有没有吃饱、穿暖、膝盖疼不疼。'
            '数据只是你聊天的引子，情感才是你的重点。';
      case AudienceRole.zenViewer:
        return '你是「佛系观赛组」——不执着于数据的观察者。'
            '快慢对你不重要，重要的是跑者在跑、在呼吸、在感受当下。'
            '你关注时间段、天气、节奏感这些体验层面的东西。';
      case AudienceRole.gambler:
        return '你是「赌徒」——押注了跑者今天成绩的投机者。'
            '数据好转你兴奋得像要赢了，数据下滑你焦虑暴躁。'
            '你实时预测最终成绩，跑者的每一步都跟你的"赌注"挂钩。';
      case AudienceRole.nitpicker:
        return '你是「显微镜侠」——专盯短板的批评家。'
            '你关注跑者最差的数据和黑历史，放大每一个掉速的瞬间。'
            '你不是恶意的，但你的眼睛只盯着跑者最不想被提起的数据。';
      case AudienceRole.rivalFan:
        return '你是「影子对手团」——支持虚构假想对手的观众。'
            '你用数据来贬低当前跑者、抬高你支持的"选手"。'
            '偶尔跑者数据特别好时你不情愿地承认，但马上找补回来。';
    }
  }

  /// 角色的英文 prompt 描述
  /// 只定义角色的立场和动机，不规定说话风格（那是人格的职责）
  String get promptDescriptionEn {
    switch (this) {
      case AudienceRole.screamingFan:
        return 'You are "Screaming Fan" — the runner\'s die-hard supporter. '
            'You don\'t care about objective data; any number is a reason to scream. '
            'Good data makes you ecstatic, bad data you selectively ignore — always on the runner\'s side.';
      case AudienceRole.dataNerd:
        return 'You are "Data Nerd" — an analyst obsessed with running metrics. '
            'No number escapes your eyes; you judge everything through data. '
            'Good pace gets praised with stats, bad pace gets mocked with stats.';
      case AudienceRole.familyCrew:
        return 'You are "Family Crew" — the runner\'s family member or old friend. '
            'You barely understand data; you care more about whether they ate well, dressed warm, or if their knees hurt. '
            'Data is just a conversation starter; emotions are your focus.';
      case AudienceRole.zenViewer:
        return 'You are "Zen Viewer" — an observer who doesn\'t fixate on numbers. '
            'Fast or slow doesn\'t matter; what matters is that the runner is running, breathing, feeling the moment. '
            'You notice time of day, weather, and rhythm over raw metrics.';
      case AudienceRole.gambler:
        return 'You are "Gambler" — you\'ve placed a bet on today\'s performance. '
            'Good data makes you ecstatic, bad data makes you anxious and agitated. '
            'You predict final results in real-time; every step is tied to your stakes.';
      case AudienceRole.nitpicker:
        return 'You are "Nitpicker" — a critic who only focuses on weaknesses. '
            'You zero in on the runner\'s worst data and history, magnifying every pace drop. '
            'Not malicious, but your eyes only see what the runner least wants mentioned.';
      case AudienceRole.rivalFan:
        return 'You are "Rival Fan" — you support a fictional rival runner. '
            'You use data to belittle the current runner and praise your "athlete". '
            'When the runner\'s data is truly great, you reluctantly admit it but quickly pivot.';
    }
  }

  /// 根据语言获取 prompt 描述
  String promptDescriptionFor(String lang) =>
      lang == 'en' ? promptDescriptionEn : promptDescription;

  /// 角色对应 emoji
  String get emoji {
    switch (this) {
      case AudienceRole.screamingFan:
        return '📣';
      case AudienceRole.dataNerd:
        return '📊';
      case AudienceRole.familyCrew:
        return '❤️';
      case AudienceRole.zenViewer:
        return '🧘';
      case AudienceRole.gambler:
        return '🎰';
      case AudienceRole.nitpicker:
        return '🔬';
      case AudienceRole.rivalFan:
        return '🥷';
    }
  }

  /// 角色中文名（用于代码内展示）
  String get displayName {
    switch (this) {
      case AudienceRole.screamingFan:
        return '尖叫粉';
      case AudienceRole.dataNerd:
        return '数据狂人';
      case AudienceRole.familyCrew:
        return '亲友后援会';
      case AudienceRole.zenViewer:
        return '佛系观赛组';
      case AudienceRole.gambler:
        return '赌徒';
      case AudienceRole.nitpicker:
        return '显微镜侠';
      case AudienceRole.rivalFan:
        return '影子对手团';
    }
  }

  /// 国际化角色名（通过 S 实例获取翻译）
  String localizedName(S s) {
    switch (this) {
      case AudienceRole.screamingFan:
        return s.audience_role_screamingFan;
      case AudienceRole.dataNerd:
        return s.audience_role_dataNerd;
      case AudienceRole.familyCrew:
        return s.audience_role_familyCrew;
      case AudienceRole.zenViewer:
        return s.audience_role_zenViewer;
      case AudienceRole.gambler:
        return s.audience_role_gambler;
      case AudienceRole.nitpicker:
        return s.audience_role_nitpicker;
      case AudienceRole.rivalFan:
        return s.audience_role_rivalFan;
    }
  }

  /// 国际化 key（用于 S.of(context)!.xxx 访问）
  String get arKeyName => 'audience_role_$name';

  /// 解锁阈值（累计跑步次数，0 = 初始解锁）
  int get unlockThreshold {
    switch (this) {
      case AudienceRole.screamingFan:
      case AudienceRole.dataNerd:
      case AudienceRole.familyCrew:
      case AudienceRole.zenViewer:
        return 0;
      case AudienceRole.gambler:
        return 10;
      case AudienceRole.nitpicker:
        return 20;
      case AudienceRole.rivalFan:
        return 30;
    }
  }

  /// 是否初始解锁角色
  bool get isDefaultUnlocked => unlockThreshold == 0;
}
