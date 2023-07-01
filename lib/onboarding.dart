import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'main.dart';


class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  // Making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
      pageColor: Colors.indigo.shade100,
      // iconImageAssetPath: 'assets/air-hostess.png',
      bubble: Image.asset('assets/images/onboarding/welcomelogo.png'),
      body: const Text(
        'Get ready to explore, learn, and be amazed!',
      ),
      title: const Text(
        'Welcome',
      ),
      titleTextStyle:
          const TextStyle(color: Colors.white),
      bodyTextStyle: const TextStyle( color: Colors.white),
      mainImage: Image.asset(
        'assets/images/onboarding/bienvenue.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
    ),
    PageViewModel(
      pageColor: Colors.indigo.shade200,
      // iconImageAssetPath: 'assets/air-hostess.png',
      bubble: Image.asset('assets/images/onboarding/Cours Logo.png'),
      body: const Text(
        'Explore our in-depth courses on various astronomical concepts',
      ),
      title: const Text(
        'Courses',
      ),
      titleTextStyle:
          const TextStyle(color: Colors.white),
      bodyTextStyle: const TextStyle( color: Colors.white),
      mainImage: Image.asset(
        'assets/images/onboarding/Cours_main.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
    ),
     PageViewModel(
      pageColor: Colors.indigo.shade400,
      // iconImageAssetPath: 'assets/air-hostess.png',
      bubble: Image.asset('assets/images/onboarding/quizLogo.webp'),
      body: const Text(
        'Test your knowledge with our interactive quizzes on astronomy.',
      ),
      title: const Text(
        'Quizz',
      ),
      titleTextStyle:
          const TextStyle(color: Colors.white),
      bodyTextStyle: const TextStyle( color: Colors.white),
      mainImage: Image.asset(
        'assets/images/onboarding/quizMain.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
    ),
     PageViewModel(
      pageColor: Colors.indigo.shade600,
      // iconImageAssetPath: 'assets/air-hostess.png',
      bubble: Image.asset('assets/images/onboarding/galeriLogo.png'),
      body: const Text(
        'Dive into our collection of stunning and captivating astronomical photos.',
      ),
      title: const Text(
        'Photo library',
      ),
      titleTextStyle:
          const TextStyle(color: Colors.white),
      bodyTextStyle: const TextStyle( color: Colors.white),
      mainImage: Image.asset(
        'assets/images/onboarding/phototequeMain.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
    ),
     PageViewModel(
      pageColor: Colors.indigo.shade800,
      // iconImageAssetPath: 'assets/air-hostess.png',
      bubble: Image.asset('assets/images/onboarding/lexiqueLogo.png'),
      body: const Text(
        'Explore our comprehensive glossary to understand astronomical terms.',
      ),
      title: const Text(
        'Glossary',
      ),
      titleTextStyle:
          const TextStyle(color: Colors.white),
      bodyTextStyle: const TextStyle( color: Colors.white),
      mainImage: Image.asset(
        'assets/images/onboarding/lexiqueMAin.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
    ),
    PageViewModel(
      pageColor: Colors.indigo.shade900,
      iconImageAssetPath: 'assets/images/onboarding/actuLogo.png',
      body: const Text(
        'Stay updated with the latest news and discoveries in the field of astronomy.',
      ),
      title: const Text('News'),
      mainImage: Image.asset(
        'assets/images/onboarding/actuMain.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      titleTextStyle:
          const TextStyle( color: Colors.white),
      bodyTextStyle: const TextStyle(color: Colors.white),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => IntroViewsFlutter(
          pages,
          // showNextButton: true,
          // showBackButton: true,
          onTapDoneButton: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          pageButtonTextStyles: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}


