# QuizZone
Quiz Zone - Projeto CM 2025-2026 

QuizZone
Descrição do Projeto

O QuizZone é uma aplicação móvel desenvolvida em Flutter que tem como objetivo proporcionar uma experiência de aprendizagem e entretenimento através de quizzes interativos. A aplicação permite aos utilizadores testar os seus conhecimentos em diversas áreas temáticas, acompanhar o seu progresso e participar em diferentes modos de jogo.

O projeto foi desenvolvido no âmbito da unidade curricular de Computação Móvel da Licenciatura em Engenharia Informática da Escola Superior de Tecnologia de Setúbal.

Objetivos

Os principais objetivos da aplicação são:

Proporcionar uma experiência de jogo intuitiva e interativa;
Incentivar a aprendizagem através de perguntas de conhecimento geral;
Implementar um sistema de progressão baseado em experiência (XP) e níveis;
Disponibilizar diferentes modos de jogo para aumentar o envolvimento dos utilizadores;
Aplicar os conhecimentos adquiridos na unidade curricular de Computação Móvel.
Funcionalidades
Ecrã Principal

O ecrã principal permite ao utilizador visualizar:

Informação do perfil (nome, nível e experiência);
Desafio diário disponível;
Modos de jogo existentes;
Categorias disponíveis;
Barra de navegação para acesso às diferentes áreas da aplicação.
Modos de Jogo

A aplicação disponibiliza vários modos de jogo:

Modo Clássico – conjunto de perguntas com número fixo;
Modo Contra-Tempo – responder ao maior número de perguntas num tempo limitado;
Modo Survival – o jogo termina após a primeira resposta incorreta;
Desafio Diário – desafio especial renovado diariamente para todos os utilizadores.
Categorias

As perguntas encontram-se organizadas por categorias:

Ciência;
História;
Desporto;
Cinema;
Geografia;
Arte.
Tecnologias Utilizadas
Flutter
Dart
Material Design 3
Android Studio
Git
GitHub
Estrutura do Projeto
lib/
│
├── main.dart
├── screens/
│   └── home_screen.dart
│
├── theme/
│   └── app_theme.dart
│
├── widgets/
├── models/
├── services/
└── utils/
Organização dos Componentes
main.dart – ponto de entrada da aplicação;
screens/ – ecrãs principais da aplicação;
theme/ – definição do tema, cores e estilos globais;
widgets/ – componentes reutilizáveis;
models/ – modelos de dados;
services/ – comunicação com APIs e bases de dados;
utils/ – funções auxiliares.
Interface Gráfica

A interface foi desenvolvida seguindo os princípios do Material Design 3, privilegiando:

Simplicidade visual;
Facilidade de utilização;
Consistência gráfica;
Navegação intuitiva;
Responsividade para diferentes tamanhos de ecrã.

O tema visual da aplicação encontra-se centralizado na classe AppTheme, permitindo uma gestão consistente das cores e estilos utilizados.

Execução da Aplicação
Instalar dependências
flutter pub get
Executar a aplicação
flutter run
Autores

Projeto desenvolvido por:

André Mendes Nº 201902460
Carolina Lobo Nº 201900888
Matheus dos Santos Nº 202001764

Licenciatura em Engenharia Informática

Escola Superior de Tecnologia de Setúbal – Instituto Politécnico de Setúbal

Ano Letivo 2025/2026

Considerações Finais

O QuizZone foi desenvolvido com o objetivo de consolidar os conhecimentos adquiridos ao longo da unidade curricular de Computação Móvel, aplicando conceitos de desenvolvimento de aplicações móveis, organização modular de código, design de interfaces e boas práticas de programação.