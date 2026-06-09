import 'package:flutter/material.dart';

/// Categoria disponível para quizzes da Open Trivia API.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.translatedName,
    required this.color,
    required this.icon,
  });

  final int id;
  final String name;
  final String translatedName;
  final Color color;
  final IconData icon;
}

/// Lista de categorias mostradas na home.
///
/// O `id` corresponde ao identificador usado pela Open Trivia API.
const List<Category> categories = [
  Category(
    id: 9,
    name: 'General Knowledge',
    translatedName: 'Conhecimento Geral',
    color: Color(0xFF5C6BC0),
    icon: Icons.lightbulb_rounded,
  ),
  Category(
    id: 10,
    name: 'Entertainment: Books',
    translatedName: 'Livros',
    color: Color(0xFF8D6E63),
    icon: Icons.menu_book_rounded,
  ),
  Category(
    id: 11,
    name: 'Entertainment: Film',
    translatedName: 'Cinema',
    color: Color(0xFFE53935),
    icon: Icons.movie_rounded,
  ),
  Category(
    id: 12,
    name: 'Entertainment: Music',
    translatedName: 'Música',
    color: Color(0xFFEC407A),
    icon: Icons.music_note_rounded,
  ),
  Category(
    id: 13,
    name: 'Entertainment: Musicals & Theatres',
    translatedName: 'Musicais e Teatro',
    color: Color(0xFFAB47BC),
    icon: Icons.theater_comedy_rounded,
  ),
  Category(
    id: 14,
    name: 'Entertainment: Television',
    translatedName: 'Televisão',
    color: Color(0xFF7E57C2),
    icon: Icons.tv_rounded,
  ),
  Category(
    id: 15,
    name: 'Entertainment: Video Games',
    translatedName: 'Videojogos',
    color: Color(0xFF43A047),
    icon: Icons.sports_esports_rounded,
  ),
  Category(
    id: 16,
    name: 'Entertainment: Board Games',
    translatedName: 'Jogos de Tabuleiro',
    color: Color(0xFFFB8C00),
    icon: Icons.casino_rounded,
  ),
  Category(
    id: 17,
    name: 'Science & Nature',
    translatedName: 'Ciência e Natureza',
    color: Color(0xFF26A69A),
    icon: Icons.eco_rounded,
  ),
  Category(
    id: 18,
    name: 'Science: Computers',
    translatedName: 'Computadores',
    color: Color(0xFF1E88E5),
    icon: Icons.computer_rounded,
  ),
  Category(
    id: 19,
    name: 'Science: Mathematics',
    translatedName: 'Matemática',
    color: Color(0xFF00ACC1),
    icon: Icons.calculate_rounded,
  ),
  Category(
    id: 20,
    name: 'Mythology',
    translatedName: 'Mitologia',
    color: Color(0xFF6D4C41),
    icon: Icons.castle_rounded,
  ),
  Category(
    id: 21,
    name: 'Sports',
    translatedName: 'Desporto',
    color: Color(0xFF7CB342),
    icon: Icons.sports_soccer_rounded,
  ),
  Category(
    id: 22,
    name: 'Geography',
    translatedName: 'Geografia',
    color: Color(0xFF29B6F6),
    icon: Icons.public_rounded,
  ),
  Category(
    id: 23,
    name: 'History',
    translatedName: 'História',
    color: Color(0xFFA1887F),
    icon: Icons.history_edu_rounded,
  ),
  Category(
    id: 24,
    name: 'Politics',
    translatedName: 'Política',
    color: Color(0xFF546E7A),
    icon: Icons.account_balance_rounded,
  ),
  Category(
    id: 25,
    name: 'Art',
    translatedName: 'Arte',
    color: Color(0xFFD81B60),
    icon: Icons.palette_rounded,
  ),
  Category(
    id: 26,
    name: 'Celebrities',
    translatedName: 'Celebridades',
    color: Color(0xFFFFB300),
    icon: Icons.star_rounded,
  ),
  Category(
    id: 27,
    name: 'Animals',
    translatedName: 'Animais',
    color: Color(0xFF66BB6A),
    icon: Icons.pets_rounded,
  ),
  Category(
    id: 28,
    name: 'Vehicles',
    translatedName: 'Veículos',
    color: Color(0xFFF4511E),
    icon: Icons.directions_car_rounded,
  ),
  Category(
    id: 29,
    name: 'Entertainment: Comics',
    translatedName: 'Banda Desenhada',
    color: Color(0xFFFF7043),
    icon: Icons.auto_stories_rounded,
  ),
  Category(
    id: 30,
    name: 'Science: Gadgets',
    translatedName: 'Gadgets',
    color: Color(0xFF26C6DA),
    icon: Icons.devices_other_rounded,
  ),
  Category(
    id: 31,
    name: 'Entertainment: Japanese Anime & Manga',
    translatedName: 'Anime e Manga',
    color: Color(0xFFEF5350),
    icon: Icons.animation_rounded,
  ),
  Category(
    id: 32,
    name: 'Entertainment: Cartoon & Animations',
    translatedName: 'Desenhos Animados',
    color: Color(0xFFFFA726),
    icon: Icons.movie_creation_rounded,
  ),
];
