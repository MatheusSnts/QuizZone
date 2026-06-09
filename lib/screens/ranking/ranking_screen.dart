import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../database/profile_database.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';


/// Ecrã de ranking global.
/// Apresenta os jogadores ordenados por XP
/// e destaca o utilizador autenticado.
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Text(
                    'Leaderboard',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Top jogadores esta semana',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Lista de jogadores.
                  Expanded(
                    child: StreamBuilder<List<UserProfile>>(
                      stream: ProfileDatabase().leaderboard(),
                      builder: (context, snapshot) {
                        // Loading.
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final players = snapshot.data!;

                        // Sem jogadores.
                        if (players.isEmpty) {
                          return const Center(
                            child: Text(
                              'Ainda não existem jogadores.',
                            ),
                          );
                        }

                        final currentUserName =
                            authService.value.currentUser?.displayName;

                        return ListView.separated(
                          itemCount: players.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final player = players[index];

                            // Destaca o utilizador autenticado.
                            final isCurrentUser =
                                player.username == currentUserName;

                            return _RankingPlayerTile(
                              position: index + 1,
                              player: player,
                              highlighted: isCurrentUser,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Barra de navegação inferior.
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
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
          if (index == 0) {
            context.go('/home');
          }

          if (index == 2) {
            context.go('/profile');
          }
        },
      ),
    );
  }
}

/// Cartão individual de jogador.
/// Mostra posição, avatar, nome,
/// nível e XP total.
class _RankingPlayerTile extends StatelessWidget {
  const _RankingPlayerTile({
    required this.position,
    required this.player,
    required this.highlighted,
  });

  final int position;
  final UserProfile player;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFF3E8FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: highlighted
            ? Border.all(
                color: const Color(0xFFD8B4FE),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Posição no ranking.
          Text(
            '$position',
            style: theme.textTheme.titleLarge,
          ),

          const SizedBox(width: 18),

          // Avatar.
          CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.primaries[position % Colors.primaries.length],
            child: Text(
              player.username
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Nome + nível.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Nível ${player.level}',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // XP.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.xp}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}