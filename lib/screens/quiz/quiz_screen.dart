import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../models/quiz_question.dart';
import '../../services/auth_service.dart';
import '../../database/profile_database.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final ProfileDatabase _profileDatabase = ProfileDatabase();

  late Future<List<_GameQuestion>> _loadFuture;
  final List<_GameQuestion> _questions = [];

  int _index = 0;
  int _correct = 0;
  int _earnedXp = 0;
  String? _selected;
  bool _answered = false;
  bool _finished = false;
  bool _xpSaved = false;

  Category get _category =>
      categories.firstWhere((c) => c.id == widget.categoryId);

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<List<_GameQuestion>> _load() async {
    final questions = await _quizService.startCategoryQuiz(widget.categoryId);
    final games = questions.map(_GameQuestion.new).toList();
    _questions
      ..clear()
      ..addAll(games);
    return games;
  }

  void _retry() {
    setState(() {
      _index = 0;
      _correct = 0;
      _earnedXp = 0;
      _selected = null;
      _answered = false;
      _finished = false;
      _xpSaved = false;
      _loadFuture = _load();
    });
  }

  void _onAnswer(String answer) {
    if (_answered) return;
    final question = _questions[_index];
    setState(() {
      _selected = answer;
      _answered = true;
      if (answer == question.question.correctAnswer) {
        _correct++;
        _earnedXp += question.question.xpReward;
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), _next);
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    if (_xpSaved) return;
    _xpSaved = true;

    final uid = authService.value.currentUser?.uid;
    if (uid != null && _earnedXp > 0) {
      await _profileDatabase.addXp(uid, _earnedXp);
    }
  }

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
                category: _category,
                correct: _correct,
                total: _questions.length,
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
    final progress = (_index + 1) / _questions.length;
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

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
              Text(
                'Pergunta ${_index + 1} de ${_questions.length}',
                style: labelStyle,
              ),
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
              value: progress,
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
                  category: _category,
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
}

class _GameQuestion {
  late List<String> answers;
  final QuizQuestion question;

  _GameQuestion(this.question) {
    answers = [question.correctAnswer, ...question.incorrectAnswers];
    answers.shuffle();
  }

}

enum _AnswerState { idle, correct, wrong, disabled }

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

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.category,
    required this.correct,
    required this.total,
    required this.earnedXp,
  });

  final Category category;
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
            category.translatedName,
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
