import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../models/game_mode.dart';
import '../../models/quiz_question.dart';
import '../../services/auth_service.dart';
import '../../database/profile_database.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';

/// Ecrã principal da partida de quiz.
///
/// Pode funcionar por categoria (`categoryId`) ou por modo de jogo (`mode`).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.categoryId, this.mode});

  final int? categoryId;

  final GameMode? mode;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final ProfileDatabase _profileDatabase = ProfileDatabase();

  // Perguntas carregadas para a partida atual.
  late Future<List<_GameQuestion>> _loadFuture;
  final List<_GameQuestion> _questions = [];

  // Estado de progresso e pontuação da partida.
  int _index = 0;
  int _correct = 0;
  int _answeredCount = 0;
  int _earnedXp = 0;
  String? _selected;
  bool _answered = false;
  bool _finished = false;
  bool _xpSaved = false;
  bool _gameOver = false;

  // Estado usado apenas em modos com tempo limite.
  Timer? _timer;
  int _secondsLeft = 0;

  bool get _isCategoryMode => widget.categoryId != null;

  Category? get _fixedCategory => _isCategoryMode
      ? categories.firstWhere((c) => c.id == widget.categoryId)
      : null;

  Category _categoryFor(_GameQuestion game) =>
      categories.firstWhere((c) => c.id == game.question.categoryId);

  String get _title =>
      _isCategoryMode ? _fixedCategory!.translatedName : widget.mode!.title;

  int get _amount => _isCategoryMode
      ? QuizService.questionsPerGame
      : widget.mode!.questionAmount;

  Duration get _delayAfterQuestion => widget.mode == GameMode.timeAttack
      ? const Duration(milliseconds: 700)
      : const Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Carrega perguntas e prepara as respostas embaralhadas para cada uma.
  Future<List<_GameQuestion>> _load() async {
    final questions = await _quizService.startQuiz(
      amount: _amount,
      categoryId: widget.categoryId,
    );
    final games = questions.map(_GameQuestion.new).toList();
    _questions
      ..clear()
      ..addAll(games);
    return games;
  }

  /// Reinicia todo o estado da partida depois de um erro.
  void _retry() {
    _timer?.cancel();
    setState(() {
      _index = 0;
      _correct = 0;
      _answeredCount = 0;
      _earnedXp = 0;
      _selected = null;
      _answered = false;
      _finished = false;
      _xpSaved = false;
      _gameOver = false;
      _timer = null;
      _secondsLeft = 0;
      _loadFuture = _load();
    });
    _startTimer();
  }

  /// Inicia o temporizador quando o modo de jogo tem limite de tempo.
  void _startTimer() {
    final limit = widget.mode?.timeLimitSeconds;
    if (limit == null) {
      return; // modos sem tempo
    }

    _secondsLeft = limit;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _finished) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _finish();
      }
    });
  }

  /// Processa a resposta escolhida, calcula XP e aplica regras do modo.
  void _onAnswer(String answer) {
    if (_answered || _finished) return;
    final question = _questions[_index];
    final correct = answer == question.question.correctAnswer;
    setState(() {
      _selected = answer;
      _answered = true;
      _answeredCount++;
      if (correct) {
        _correct++;
        _earnedXp += question.question.xpReward;
      } else if (widget.mode?.isSurvival == true) {
        _gameOver = true;
      }
    });
    Future.delayed(_delayAfterQuestion, _next);
  }

  /// Avança para a próxima pergunta ou termina a partida.
  void _next() {
    if (_finished) return;
    if (_gameOver || _index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  /// Finaliza a partida e guarda o XP ganho uma única vez.
  Future<void> _finish() async {
    _timer?.cancel();
    if (mounted) setState(() => _finished = true);
    if (_xpSaved) return;
    _xpSaved = true;

    final uid = authService.value.currentUser?.uid;
    if (uid != null && _earnedXp > 0) {
      await _profileDatabase.addXp(uid, _earnedXp);
    }
  }

  /// Confirma saída para evitar perder progresso por engano.
  Future<void> _confirmExit() async {
    if (_finished || _questions.isEmpty) {
      context.go('/home');
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do jogo?'),
        content: const Text('Vais perder o progresso desta partida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (leave == true && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<_GameQuestion>>(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }
            if (snapshot.hasError) {
              return _ErrorView(onRetry: _retry);
            }
            if (_finished) {
              return _ResultView(
                subtitle: _title,
                correct: _correct,
                total: _answeredCount,
                earnedXp: _earnedXp,
              );
            }
            return _buildGame();
          },
        ),
      ),
    );
  }

  Widget _buildGame() {
    final theme = Theme.of(context);

    final game = _questions[_index];
    final isTimeAttack = widget.mode == GameMode.timeAttack;
    final accent = widget.mode?.color ?? theme.colorScheme.primary;
    final displayCategory = _isCategoryMode
        ? _fixedCategory!
        : _categoryFor(game);

    // No contra-tempo, a barra representa segundos restantes; nos outros
    // modos, representa o avanço nas perguntas.
    final double progress = isTimeAttack
        ? _secondsLeft / widget.mode!.timeLimitSeconds!
        : (_index + 1) / _questions.length;

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: accent,
      fontWeight: FontWeight.w700,
    );

    final String leftLabel;
    if (isTimeAttack) {
      leftLabel = _formatTime(_secondsLeft);
    } else if (widget.mode?.isSurvival == true) {
      leftLabel = 'Pergunta ${_index + 1}';
    } else {
      leftLabel = 'Pergunta ${_index + 1} de ${_questions.length}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _CircleIconButton(
            icon: Icons.close_rounded,
            onTap: _confirmExit,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              if (isTimeAttack)
                Icon(Icons.timer_rounded, size: 18, color: accent)
              else if (widget.mode?.isSurvival == true)
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: accent,
                ),
              if (isTimeAttack || widget.mode?.isSurvival == true)
                const SizedBox(width: 6),

              Text(leftLabel, style: labelStyle),
              const Spacer(),
              Text('$_earnedXp XP', style: labelStyle),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QuestionCard(
                  category: displayCategory,
                  question: game.question.question,
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < game.answers.length; i++) ...[
                  _AnswerCard(
                    text: game.answers[i],
                    state: _answerState(game, game.answers[i]),
                    onTap: () => _onAnswer(game.answers[i]),
                  ),
                  if (i != game.answers.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  _AnswerState _answerState(_GameQuestion game, String answer) {
    if (!_answered) return _AnswerState.idle;
    if (answer == game.question.correctAnswer) return _AnswerState.correct;
    if (answer == _selected) return _AnswerState.wrong;
    return _AnswerState.disabled;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}

/// Junta a pergunta às respostas embaralhadas que aparecem no ecrã.
class _GameQuestion {
  late List<String> answers;
  final QuizQuestion question;

  _GameQuestion(this.question) {
    answers = [question.correctAnswer, ...question.incorrectAnswers];
    answers.shuffle();
  }
}

/// Estado visual de uma resposta depois do jogador escolher uma opção.
enum _AnswerState { idle, correct, wrong, disabled }

/// Cartão com a categoria e o texto da pergunta atual.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.category, required this.question});

  final Category category;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [category.color, category.color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.translatedName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opção de resposta com estado visual de certo, errado ou desativado.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  static const Color _idleBackground = Color(0xFFF1F3F8);
  static const Color _textColor = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final Color answerBackground;
    Color answerText = _textColor;
    Color? answerBorder;
    IconData? answerIcon;

    switch (state) {
      case _AnswerState.idle:
        answerBackground = _idleBackground;
      case _AnswerState.correct:
        answerBackground = AppColors.success.withValues(alpha: 0.16);
        answerBorder = AppColors.success;
        answerText = const Color(0xFF0B5C42);
        answerIcon = Icons.check_circle_rounded;
      case _AnswerState.wrong:
        answerBackground = AppColors.error.withValues(alpha: 0.14);
        answerBorder = AppColors.error;
        answerText = const Color(0xFF8A1F1F);
        answerIcon = Icons.cancel_rounded;
      case _AnswerState.disabled:
        answerBackground = _idleBackground.withValues(alpha: 0.4);
        answerText = _textColor.withValues(alpha: 0.4);
    }

    return Material(
      color: answerBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: state == _AnswerState.idle ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: answerBorder ?? Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: answerText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (answerIcon != null)
                Icon(answerIcon, color: answerBorder, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: cs.onSurface),
        ),
      ),
    );
  }
}

/// Vista enquanto as perguntas estão a ser carregadas/traduzidas.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'A preparar o teu jogo...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A buscar e traduzir as perguntas.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista de erro quando não é possível carregar perguntas.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 56,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar o jogo',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Verifica a ligação à internet e tenta novamente.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }
}

/// Resumo apresentado no final da partida.
class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.subtitle,
    required this.correct,
    required this.total,
    required this.earnedXp,
  });

  final String subtitle;
  final int correct;
  final int total;
  final int earnedXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : correct / total;
    final message = ratio >= 0.8
        ? 'Excelente!'
        : ratio >= 0.5
        ? 'Bom trabalho!'
        : 'Continua a praticar!';

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 72,
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ResultStat(
                  label: 'Acertos',
                  value: '$correct / $total',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultStat(
                  label: 'XP ganho',
                  value: '+$earnedXp',
                  icon: Icons.bolt_rounded,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }
}

/// Métrica pequena usada no resumo final.
class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
