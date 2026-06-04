import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/category.dart';
import '../models/game_mode.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../database/profile_database.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = authService.value.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    final username = displayName.isNotEmpty
        ? displayName
        : (user?.email?.split('@').first ?? 'Jogador');

    return Scaffold(
      drawer: _ProfileDrawer(username: username),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(username: username),
              const SizedBox(height: 24),
              const _DailyChallengeCard(remaining: '14h 23m', questions: 10),
              const SizedBox(height: 28),
              _SectionTitle('Modos de Jogo', theme: theme),
              const SizedBox(height: 12),
              const _GameModeRow(),
              const SizedBox(height: 28),
              _SectionTitle('Categorias', theme: theme),
              const SizedBox(height: 12),
              const _CategoriesRow(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
        onDestinationSelected: (_) {},
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.theme});
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final email = authService.value.currentUser?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: cs.error),
              title: Text(
                'Terminar sessão',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await authService.value.signOut();
    if (context.mounted) context.go('/login');
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final uid = authService.value.currentUser?.uid;

    return Row(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Scaffold.of(context).openDrawer(),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: cs.primaryContainer,
            child: Text(
              username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $username',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              if (uid == null)
                Text(
                  'Nível 1  •  0 XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              else
                StreamBuilder<UserProfile>(
                  stream: ProfileDatabase().stream(uid),
                  builder: (context, snapshot) {
                    final profile = snapshot.data ?? const UserProfile(xp: 0);
                    return Text(
                      'Nível ${profile.level}  •  ${profile.xp} XP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: cs.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({
    required this.remaining,
    required this.questions,
  });

  final String remaining;
  final int questions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt_rounded, color: cs.onPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'DESAFIO DIÁRIO',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$questions perguntas para todos os jogadores',
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Termina em $remaining',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Jogar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameModeRow extends StatelessWidget {
  const _GameModeRow();

  @override
  Widget build(BuildContext context) {
    final modes = GameMode.values;
    return Row(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          Expanded(child: _GameModeCard(mode: modes[i])),
          if (i != modes.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/play/${mode.slug}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mode.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(mode.icon, color: mode.color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                mode.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mode.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _CategoryItem(category: categories[index]),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: () => context.push('/quiz/${category.id}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 25),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.translatedName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
