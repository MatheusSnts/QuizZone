import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Os modos de jogo disponíveis na home (além do quiz por categoria).
enum GameMode {
  classic(
    slug: 'classico',
    title: 'Clássico',
    subtitle: '10 perguntas',
    icon: Icons.menu_book_rounded,
    color: AppColors.seed,
    questionAmount: 10,
  ),
  timeAttack(
    slug: 'contra-tempo',
    title: 'Contra-tempo',
    subtitle: '60 segundos',
    icon: Icons.timer_rounded,
    color: AppColors.accent,
    questionAmount: 20,
    timeLimitSeconds: 60,
  ),
  survival(
    slug: 'survival',
    title: 'Survival',
    subtitle: 'Falha = fim',
    icon: Icons.local_fire_department_rounded,
    color: AppColors.error,
    questionAmount: 20,
    isSurvival: true,
  );

  const GameMode({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.questionAmount,
    this.timeLimitSeconds,
    this.isSurvival = false,
  });

  final String slug;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  final int questionAmount;

  final int? timeLimitSeconds;

  final bool isSurvival;

  bool get hasTimer => timeLimitSeconds != null;

  static GameMode? fromSlug(String slug) {
    for (GameMode mode in GameMode.values) {
      if (mode.slug == slug) return mode;
    }
    return null;
  }
}
