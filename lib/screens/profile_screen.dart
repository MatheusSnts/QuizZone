import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/profile_database.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Ecrã de perfil do jogador.
///
/// Combina dados da conta Firebase com o XP guardado em Firestore.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileDatabase _database = ProfileDatabase();

  Stream<UserProfile>? _profileStream;

  @override
  void initState() {
    super.initState();
    final uid = authService.value.currentUser?.uid;
    if (uid != null) {
      _profileStream = _database.stream(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    final username = displayName.isNotEmpty
        ? displayName
        : (user?.email?.split('@').first ?? 'Jogador');
    final email = user?.email ?? 'Sem email associado';

    return Scaffold(
      body: SafeArea(
        child: _profileStream == null
            ? _SignedOutView(username: username)
            : StreamBuilder<UserProfile>(
                stream: _profileStream,
                builder: (context, snapshot) {
                  final profile = snapshot.data ?? const UserProfile(xp: 0);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(onBack: () => context.go('/home')),
                        const SizedBox(height: 20),
                        _ProfileHeader(
                          username: username,
                          email: email,
                          profile: profile,
                        ),
                        const SizedBox(height: 24),
                        _LevelProgress(profile: profile),
                        const SizedBox(height: 24),
                        _StatsGrid(profile: profile),
                        const SizedBox(height: 24),
                        _AccountActions(email: email),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
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
        onDestinationSelected: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/ranking');
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
        const SizedBox(width: 4),
        Text(
          'Perfil',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Cabeçalho com avatar, nome, email e nível atual.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.username,
    required this.email,
    required this.profile,
  });

  final String username;
  final String email;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final initial = username.trim().isEmpty
        ? 'J'
        : username.trim().substring(0, 1).toUpperCase();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: cs.primaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LevelBadge(level: profile.level),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pequeno selo visual para destacar o nível do jogador.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 18),
          const SizedBox(width: 6),
          Text(
            'Nível $level',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão com a barra de progresso até ao próximo nível.
class _LevelProgress extends StatelessWidget {
  const _LevelProgress({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final remaining = UserProfile.xpPerLevel - profile.xpToLevelUp;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.trending_up_rounded, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso do nível',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$remaining XP para o nível ${profile.level + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: profile.levelProgress,
                backgroundColor: cs.surfaceContainerHighest,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${profile.xpToLevelUp} XP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${UserProfile.xpPerLevel} XP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grelha de métricas calculadas a partir do XP do perfil.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _StatCard(
          icon: Icons.bolt_rounded,
          label: 'XP total',
          value: profile.xp.toString(),
          color: AppColors.accent,
        ),
        _StatCard(
          icon: Icons.flag_rounded,
          label: 'Nível atual',
          value: profile.level.toString(),
          color: Theme.of(context).colorScheme.primary,
        ),
        _StatCard(
          icon: Icons.psychology_rounded,
          label: 'XP neste nível',
          value: profile.xpToLevelUp.toString(),
          color: AppColors.success,
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'XP em falta',
          value: (UserProfile.xpPerLevel - profile.xpToLevelUp).toString(),
          color: AppColors.error,
        ),
      ],
    );
  }
}

/// Cartão reutilizável para cada métrica do perfil.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão com as ações de conta (email e terminar sessão).
class _AccountActions extends StatelessWidget {
  const _AccountActions({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Conta'),
            subtitle: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: cs.error),
            title: Text(
              'Terminar sessão',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await authService.value.signOut();
    if (context.mounted) context.go('/login');
  }
}

/// Estado de fallback caso o ecrã seja aberto sem sessão ativa.
class _SignedOutView extends StatelessWidget {
  const _SignedOutView({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 52),
            const SizedBox(height: 14),
            Text(
              'Sessão terminada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$username, inicia sessão para veres o teu perfil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Ir para login'),
            ),
          ],
        ),
      ),
    );
  }
}
