import 'package:flutter/material.dart';

class ScreenDirection {
  final String routeName;

  ScreenDirection(this.routeName);
}


class Accueil extends StatelessWidget {

final List<Map<String, dynamic>> _introData = [
  {
    'title': 'Cours',
    'image': 'assets/images/Intro_screen/cours.webp',
    'direction': ScreenDirection('/cours'), // Direction vers l'écran de cours
  },
  {
    'title': 'Quizz',
    'image': 'assets/images/Intro_screen/quizz.webp',
    'direction': ScreenDirection('/quizz'), // Direction vers l'écran de quizz
  },
  {
    'title': 'Photothèque',
    'image': 'assets/images/Intro_screen/galerie.webp',
    'direction': ScreenDirection('/phototheque'), // Direction vers l'écran de photothèque
  },
  {
    'title': 'Forum',
    'image': 'assets/images/Intro_screen/forum.webp',
    'direction': ScreenDirection('/forum'), // Direction vers l'écran de forum
  },
  {
    'title': 'Lexique',
    'image': 'assets/images/Intro_screen/lexique.webp',
    'direction': ScreenDirection('/lexique'), // Direction vers l'écran de lexique
  },
  {
    'title': 'Actualités',
    'image': 'assets/images/Intro_screen/actualites.png',
    'direction': ScreenDirection('/actualites'), // Direction vers l'écran d'actualités
  },
];


  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: _introData.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            onTap: () {
              // Navigation vers la direction correspondante
              Navigator.pushNamed(context, _introData[index]['direction'].route);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.0),
                    ),
                    child: Image.asset(
                      _introData[index]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _introData[index]['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


}