import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/rp_animations.dart';
import '../domain/audience_roles.dart';
import '../domain/personalities.dart';
import '../providers.dart';
import 'interview_state.dart';
import 'widgets/interview_input_bar.dart';
import 'widgets/interview_message_bubble.dart';

/// 赛后采访页面 — 与观众角色进行赛后对话
class InterviewScreen extends ConsumerStatefulWidget {
  final int sessionId;
  final AudienceRole role;
  final Personality personality;

  const InterviewScreen({
    super.key,
    required this.sessionId,
    required this.role,
    required this.personality,
  });

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  late final TextEditingController _inputCtrl;
  late final ScrollController _scrollCtrl;
  late final FocusNode _focusNode;

  InterviewArgs get _args => (
        sessionId: widget.sessionId,
        role: widget.role,
        personality: widget.personality,
      );

  @override
  void initState() {
    super.initState();
    _inputCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(interviewProvider(_args).notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final state = ref.watch(interviewProvider(_args));

    ref.listen(interviewProvider(_args), (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: context.rpBg,
      appBar: _buildAppBar(context, s, state),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(context, s, state)),
          InterviewInputBar(
            controller: _inputCtrl,
            focusNode: _focusNode,
            isStreaming: state.isStreaming,
            onSend: _onSend,
            onChanged: (v) =>
                ref.read(interviewProvider(_args).notifier).updateInput(v),
            onStop: () =>
                ref.read(interviewProvider(_args).notifier).stop(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, S s, InterviewState state) {
    return AppBar(
      backgroundColor: context.rpBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.rpText),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.role.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.role.localizedName(s)} · ${widget.personality.localizedName(s)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.rpText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  s.audience_interviewTitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.rpMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        if (state.isStreaming)
          IconButton(
            icon: Icon(Icons.stop_circle_outlined, color: context.rpAccent),
            onPressed: () =>
                ref.read(interviewProvider(_args).notifier).stop(),
            tooltip: 'Stop',
          ),
      ],
    );
  }

  Widget _buildMessageList(
      BuildContext context, S s, InterviewState state) {
    if (state.messages.isEmpty && !state.isStreaming) {
      return Center(
        child: RpFadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.role.emoji,
                    style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  s.audience_interviewOpening(widget.role.localizedName(s)),
                  style: TextStyle(fontSize: 16, color: context.rpMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isLast = index == state.messages.length - 1;
        return InterviewMessageBubble(
          message: msg,
          role: widget.role,
          isStreaming: isLast && state.isStreaming,
        );
      },
    );
  }

  void _onSend(String text) {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    final notifier = ref.read(interviewProvider(_args).notifier);
    notifier.updateInput('');
    notifier.sendMessage(text);
    _focusNode.unfocus();
  }
}
