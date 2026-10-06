import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/widgets/table_reservation_sheet.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/scout_ai/presentation/widgets/plan_card.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/services/ai/ai_service.dart';

// =============================================================================
// Scout Conversation State Management
// =============================================================================

class ScoutChatNotifier extends StateNotifier<List<AiMessage>> {
  final AiService _aiService;
  StreamSubscription<AiMessage>? _streamSub;

  ScoutChatNotifier(this._aiService) : super([]);

  void addMessage(AiMessage msg) {
    state = [...state, msg];
  }

  void updateFeedback(String messageId, String feedback) {
    state = state.map((m) {
      if (m.id == messageId) {
        return m.copyWith(feedback: m.feedback == feedback ? null : feedback);
      }
      return m;
    }).toList();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AiMessage(
      id: 'msg_u_${DateTime.now().millisecondsSinceEpoch}',
      role: AiMessageRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];

    // Placeholder assistant message while waiting
    final assistantMsgId = 'msg_a_${DateTime.now().millisecondsSinceEpoch}';
    final placeholder = AiMessage(
      id: assistantMsgId,
      role: AiMessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    state = [...state, placeholder];

    await _streamSub?.cancel();
    _streamSub = _aiService.chat(state).listen(
      (streamedMsg) {
        state = state.map((m) {
          if (m.id == assistantMsgId) {
            return streamedMsg;
          }
          return m;
        }).toList();
      },
      onError: (err) {
        state = state.map((m) {
          if (m.id == assistantMsgId) {
            return AiMessage(
              id: assistantMsgId,
              role: AiMessageRole.assistant,
              content: 'Sorry, I encountered an issue. Here are some trending experiences instead.',
              timestamp: DateTime.now(),
            );
          }
          return m;
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

final scoutChatProvider =
    StateNotifierProvider<ScoutChatNotifier, List<AiMessage>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return ScoutChatNotifier(aiService);
});

// =============================================================================
// Scout AI Screen
// =============================================================================

class ScoutScreen extends ConsumerStatefulWidget {
  const ScoutScreen({super.key});

  @override
  ConsumerState<ScoutScreen> createState() => _ScoutScreenState();
}

class _ScoutScreenState extends ConsumerState<ScoutScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _selectedLocale = 'en_IN';
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _waveAnimController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceInput() async {
    HapticFeedback.mediumImpact();

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onError: (err) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice error: ${err.errorMsg}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: _selectedLocale,
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is unavailable on this device/browser.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sendMessage([String? overrideText]) {
    final text = overrideText ?? _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(scoutChatProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  List<String> _getContextAwareChips() {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    final chips = <String>[];

    // 1. Time of Day chip
    if (hour < 12) {
      chips.add('🌅 Morning Matinees & 20% OFF');
    } else if (hour < 17) {
      chips.add('🍿 Afternoon Blockbusters');
    } else if (hour < 21) {
      chips.add('🍷 Dinner + Movie Night Out');
    } else {
      chips.add('🌙 Late Night IMAX Shows');
    }

    // 2. Day of Week chip
    if (weekday == DateTime.friday) {
      chips.add('🎭 Friday Live Standup Comedy');
    } else if (weekday == DateTime.tuesday) {
      chips.add('🎟️ Tuesday 50% OFF Deals');
    } else if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      chips.add('⭐ Weekend Premieres in Mumbai');
    } else {
      chips.add('🎬 Must-Watch Trending Movies');
    }

    // 3. City chip
    chips.add('🍽️ Top Dining near Lower Parel');

    return chips;
  }

  String _getTimeGreeting(String userName) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $userName!';
    if (hour < 17) return 'Good afternoon, $userName!';
    if (hour < 21) return 'Good evening, $userName!';
    return 'Hey, $userName!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);
    final userName = userAsync.value?.name ?? 'Alex';
    final chatMessages = ref.watch(scoutChatProvider);
    final contextChips = _getContextAwareChips();

    ref.listen(scoutChatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            AppSpacing.horizontal12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Scout AI',
                      style: AppTypography.heading18(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'BETA',
                        style: TextStyle(
                          color: AppColors.spotlightCoral,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Your intelligent entertainment concierge',
                  style: AppTypography.caption12(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language selector toggle (English / Hindi)
          PopupMenuButton<String>(
            tooltip: 'Voice Language',
            initialValue: _selectedLocale,
            onSelected: (loc) => setState(() => _selectedLocale = loc),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'en_IN', child: Text('English (India)')),
              PopupMenuItem(value: 'hi_IN', child: Text('Hindi (भारत)')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded, size: 18, color: AppColors.marqueeAmber),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLocale == 'en_IN' ? 'EN' : 'HI',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.marqueeAmber),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat history or Greeting with Suggestion chips
          Expanded(
            child: chatMessages.isEmpty
                ? _buildEmptyGreetingState(context, userName, contextChips, isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = chatMessages[index];
                      return _buildMessageBubble(context, msg, isDark);
                    },
                  ),
          ),

          // Listening Waveform banner when microphone active
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.spotlightCoral.withValues(alpha: 0.15),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _waveAnimController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(
                          5,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 3,
                            height: 10 + (sin((_waveAnimController.value * pi) + (i * 0.8)) * 12).abs(),
                            decoration: BoxDecoration(
                              color: AppColors.spotlightCoral,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Listening (${_selectedLocale == "en_IN" ? "English" : "Hindi"})... Speak now',
                    style: const TextStyle(
                      color: AppColors.spotlightCoral,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_rounded, color: AppColors.spotlightCoral, size: 20),
                    onPressed: _toggleVoiceInput,
                  ),
                ],
              ),
            ),

          // Bottom Input Bar with Mic & Send Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Mic button with waveform pulse
                  GestureDetector(
                    onTap: _toggleVoiceInput,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppColors.spotlightCoral
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : AppColors.spotlightCoral,
                        size: 20,
                      ),
                    ),
                  ),
                  AppSpacing.horizontal8,

                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141724) : Colors.grey.shade100,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        onSubmitted: (val) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: _isListening ? 'Listening...' : 'Ask Scout: movies, food, seats...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.horizontal8,

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.spotlightCoral),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Empty State / Greeting View
  // ===========================================================================

  Widget _buildEmptyGreetingState(
    BuildContext context,
    String userName,
    List<String> chips,
    bool isDark,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _getTimeGreeting(userName),
              textAlign: TextAlign.center,
              style: AppTypography.heading24(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask me to discover blockbuster shows, book seats, plan dinner, or find comedy nights in Hindi or English.',
              textAlign: TextAlign.center,
              style: AppTypography.caption12(
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ).copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 28),

            // 3 Context-aware suggestion chips
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUGGESTED FOR YOU',
                style: TextStyle(
                  color: AppColors.marqueeAmber,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...chips.map(
              (chip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _sendMessage(chip.replaceAll(RegExp(r'^[^\w]+'), '').trim()),
                  borderRadius: AppRadius.border16,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : AppColors.lightSurface,
                      borderRadius: AppRadius.border16,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chip,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.spotlightCoral),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Message Bubble View (User vs Assistant)
  // ===========================================================================

  Widget _buildMessageBubble(BuildContext context, AiMessage msg, bool isDark) {
    final isUser = msg.role == AiMessageRole.user;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.coralGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.content,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Assistant Message with Rich Cards & Feedback
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header Tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.spotlightCoral),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Scout AI',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.spotlightCoral),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AI-generated',
                    style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Message Body Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: AppRadius.border16,
                border: Border.all(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streaming text or typing indicator
                  if (msg.content.isEmpty && msg.isStreaming)
                    _buildTypingIndicator()
                  else
                    Text(
                      msg.content,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                  // 1. Rich Event Cards
                  if (msg.events != null && msg.events!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...msg.events!.map((e) => _buildRichEventCard(context, e, isDark)),
                  ],

                  // 2. Rich Showtime Chips
                  if (msg.showtimes != null && msg.showtimes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildRichShowtimeChips(context, msg.showtimes!, isDark),
                  ],

                  // 3. Rich Restaurant Cards
                  if (msg.restaurants != null && msg.restaurants!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...msg.restaurants!.map((r) => _buildRichRestaurantCard(context, r, isDark)),
                  ],

                  // 4. Rich Plan Card
                  if (msg.plan != null) ...[
                    const SizedBox(height: 12),
                    _buildRichPlanCard(context, msg.plan!, isDark),
                  ],
                ],
              ),
            ),

            // Thumbs up / down & Suggestions row
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    msg.feedback == 'like' ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                    size: 14,
                    color: msg.feedback == 'like' ? AppColors.spotlightCoral : Colors.white38,
                  ),
                  onPressed: () => ref.read(scoutChatProvider.notifier).updateFeedback(msg.id, 'like'),
                ),
                IconButton(
                  icon: Icon(
                    msg.feedback == 'dislike' ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
                    size: 14,
                    color: msg.feedback == 'dislike' ? AppColors.spotlightCoral : Colors.white38,
                  ),
                  onPressed: () => ref.read(scoutChatProvider.notifier).updateFeedback(msg.id, 'dislike'),
                ),
                const Spacer(),
                Text(
                  DateFormat('h:mm a').format(msg.timestamp),
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),

            // Suggested response chips
            if (msg.suggestedChips != null && msg.suggestedChips!.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: msg.suggestedChips!.map((chip) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: ActionChip(
                        label: Text(chip),
                        labelStyle: const TextStyle(fontSize: 11, color: AppColors.spotlightCoral),
                        backgroundColor: AppColors.spotlightCoral.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.spotlightCoral.withValues(alpha: 0.4)),
                        onPressed: () => _sendMessage(chip),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Typing Indicator (Pulsing Dots)
  // ===========================================================================

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Scout is thinking', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _waveAnimController,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.spotlightCoral.withValues(
                      alpha: 0.3 + (sin((_waveAnimController.value * pi) + (i * 1.0)).abs() * 0.7),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // Rich Result Cards
  // ===========================================================================

  Widget _buildRichEventCard(BuildContext context, Event event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141724) : Colors.grey.shade100,
        borderRadius: AppRadius.border12,
        border: Border.all(color: AppColors.spotlightCoral.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ShowScapeImage(
              imageUrl: event.posterUrl,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          AppSpacing.horizontal12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.certificate ?? "UA"} • ${event.genres.take(2).join(", ")}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'From ₹350',
                  style: const TextStyle(color: AppColors.marqueeAmber, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spotlightCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
            ),
            onPressed: () => context.push(AppRoutes.showtimesPath(event.id)),
            child: const Text('Showtimes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRichShowtimeChips(BuildContext context, List<Show> shows, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Showtime (Goes to Seat Map):',
          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: shows.map((s) {
            final timeStr = DateFormat('h:mm a').format(s.startTime);
            return ActionChip(
              avatar: const Icon(Icons.event_seat_rounded, size: 14, color: AppColors.spotlightCoral),
              label: Text('$timeStr • ${s.screenName}'),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              backgroundColor: isDark ? const Color(0xFF1B1F30) : Colors.grey.shade200,
              side: const BorderSide(color: AppColors.spotlightCoral),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(AppRoutes.seatsPath(s.id));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRichRestaurantCard(BuildContext context, Restaurant r, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141724) : Colors.grey.shade100,
        borderRadius: AppRadius.border12,
        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              r.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade800,
                child: const Icon(Icons.restaurant, color: Colors.white38),
              ),
            ),
          ),
          AppSpacing.horizontal12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${r.cuisine.first} • ₹${r.costForTwo.toInt()} for two',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.marqueeAmber,
              foregroundColor: AppColors.midnight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
            ),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => TableReservationSheet(restaurant: r),
              );
            },
            child: const Text('Reserve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildRichPlanCard(BuildContext context, Map<String, dynamic> plan, bool isDark) {
    return PlanCard(plan: plan);
  }
}
