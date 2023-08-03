
import 'package:flutter/material.dart';

class ScreenDirection {
  final String route;

  ScreenDirection(this.route);
}

class Accueil extends StatelessWidget {
  final List<Map<String, dynamic>> _introData = [
    {
      'title': 'Courses',
      'image': 'assets/images/Intro_screen/cours.jpg',
      'direction': ScreenDirection('/cours'), // Direction vers l'écran de cours
    },
    {
      'title': 'Quizz',
      'image': 'assets/images/Intro_screen/quiz.jpg',
      'direction': ScreenDirection('/quizz'), // Direction vers l'écran de quizz
    },
    {
      'title': 'Photo Library',
      'image': 'assets/images/Intro_screen/phototheque.jpg',
      'direction': ScreenDirection('/phototheque'), // Direction vers l'écran de photothèque
    },
    {
      'title': 'Glossary',
      'image': 'assets/images/Intro_screen/lexique.jpg',
      'direction': ScreenDirection('/lexique'), // Direction vers l'écran de lexique
    },
    {
      'title': 'News',
      'image': 'assets/images/Intro_screen/actualite.jpg',
      'direction': ScreenDirection('/actualites'), // Direction vers l'écran d'actualités
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _introData.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: InkWell(
              onTap: () {
                // Navigation vers la direction correspondante
                Navigator.pushNamed(context, _introData[index]['direction'].route);
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8.0),
                        ),
                        child: Image.asset(
                          _introData[index]['image']!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              _introData[index]['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
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

